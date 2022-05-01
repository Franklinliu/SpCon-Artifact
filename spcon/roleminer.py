
from asyncio.log import logger
from pyevolve import G1DList
from pyevolve import GSimpleGA
from pyevolve import Crossovers
from pyevolve import Mutators
from pyevolve import Selectors
from pyevolve import Initializators
from pyevolve import G2DBinaryString
from pyevolve import Consts
from pyevolve import Scaling
import json
import time
import concepts
from scipy.spatial import distance
import numpy as np
import pandas as pd
import os 
from prettytable import PrettyTable
import itertools 
from functools import lru_cache
import requests
import traceback
from web3 import Web3 
import copy

NORMAL_USER = ("NORMAL_USER")

@lru_cache(maxsize=None)
def getMethodName(hex_signature):
    try:
        headers = {'X-API-KEY': 'BQYEtWs7QzCdCwkJKVhmTDp3RFTWAUEP'}
        url = f'https://www.4byte.directory/api/v1/signatures/?hex_signature={hex_signature}'
        print(url)
        response = requests.get(url, headers=headers)
        body = response.content
        methodName = json.loads(body.decode("utf8"))["results"][0]["text_signature"].split("(")[0]
        return methodName
    except:
        return hex_signature
def getABIfunctions(abi_file):
    ABIfunctions = list()
    abis = json.load(open(abi_file))
    for abi in abis:
        if abi["type"] == "function" and abi["stateMutability"]!="view":
            ABIfunctions.append(abi["name"])
    return ABIfunctions 

def getABI_file(directory):
    items = os.listdir(directory)
    abi_file = None 
    for item in items:
        if item.endswith("abi"):
            abi_file = os.path.join(directory, item)
            break 
    if abi_file:
        return abi_file
    raise Exception("ABI file not found")     

func_mappings = dict()
def getABIfunction_signature_mapping(abi):
    global func_mappings
    func_mappings = dict()
    signatures = [ (func['name'], '{}({})'.format(func['name'],','.join([input['type'] for input in func['inputs']]))) for func in [obj for obj in abi if obj['type'] == 'function']]
    names = set()
    for sig in signatures:
        name, full_name = sig 
        bytes4_sig = Web3.sha3(text=full_name)[0:4].hex()
        func_mappings[bytes4_sig] = sig
        names.add(name)

    def func(bytes4_sig):
        if bytes4_sig in names:
            return bytes4_sig
        if not bytes4_sig.startswith("0x"):
            bytes4_sig = "0x"+bytes4_sig
        if bytes4_sig in func_mappings:
            return func_mappings[bytes4_sig][0]
        else:
            return getMethodName(bytes4_sig)
    return func 
    
    

def lightweightrolemining(address, abi, gene_encoding, generation, simratio, workdir):
    starttime = time.time()
    smartcontractCalls = list()
    def getIdCounter():
            hashMap = dict()
            userMap = dict()
            def _getId(user):
                user = user.lower()
                if user in hashMap:
                    return hashMap[user]
                else:
                    hashMap[user] = len(userMap)
                    userMap[len(userMap)] = user
                    return hashMap[user]
            return userMap, _getId 
    try:
        print(os.path.join(workdir, address))
        bytes4_mapping_func = getABIfunction_signature_mapping(abi)
        print("loaded abi.")
    except:
        traceback.print_exc()
        bytes4_mapping_func = getMethodName
        pass     
    with open(os.path.join(workdir, address, "all_txs.json"), "r") as f:
        usercall_statistics = json.load(f)
    UF = list()
    functions = set()
    userMap, IdCounter = getIdCounter()
    for usercall in usercall_statistics["data"]["ethereum"]["smartContractCalls"]:
        caller, count, function, success = usercall["caller"]["address"], usercall["count"], usercall["smartContractMethod"]["name"] if usercall["smartContractMethod"]["name"]!=None else \
             bytes4_mapping_func(usercall["smartContractMethod"]["signatureHash"]),  usercall["success"]
        smartcontractCalls.append((caller, function, count, success))
        if function !="Contract Creation" and (success == 1 or success is True):
            functions.add(function)
            UF.append((IdCounter(caller), function, count))
    
    functions = list(functions)
    print(len(functions), " functions", functions)
    userLabels = [(user_id, userMap[user_id]) for user_id in userMap.keys()]
    print(len(userLabels), " users")
    freqMatrix = np.zeros((len(userLabels), len(functions)))
    freqMatrix = pd.DataFrame(data=freqMatrix, columns=functions,  index=range(len(userLabels)))  
    for user_func_count in UF:
        freqMatrix.loc[user_func_count[0], user_func_count[1]] = \
            freqMatrix.loc[user_func_count[0], user_func_count[1]] + user_func_count[2]
    
    permissionMatrix = freqMatrix.astype(bool).astype(int)
    print(f"Timecost for loading history: {time.time()-starttime}")

    roleminer = GA_RM(permissionMatrix, freqMatrix, simratio, userLabels, \
        userMap, generation = generation, gene_encoding=gene_encoding, address=address)      
    return functions, roleminer.verybasic_usergroups, roleminer.process()


hierarchyMatrix = None 
def buildRoleHierarchy(roles):
    global hierarchyMatrix
    hierarchyMatrix = np.zeros([len(roles), len(roles)])
    for i in range(len(roles)):
        for j in range(len(roles)):
            if i!=j:
                userset1 = roles[i][0]
                userset2 = roles[j][0]
                # roles[j] is the parent role of roles[j]
                # roles[i] has higher priviledge than roles[j]
                if userset1.issubset(userset2):
                    hierarchyMatrix[i, j] = 1 

removes = list()
def dfsReduceRecursive(roles, i):
        global hierarchyMatrix, removes  
        numOfparentroles = np.sum(hierarchyMatrix[i])
        numOfchildroles = np.sum(hierarchyMatrix[:,i])
        # it means the roles[i] has more permission functions than some roles 
        # and no other role has more permission functions  than roles[i]
        if numOfparentroles > 0 and numOfchildroles == 0: 
            userSet1, funcSet1 = roles[i]
            for j in range(len(hierarchyMatrix[i])):
                if hierarchyMatrix[i, j] == 1:
                    parentrole = roles[j]
                    userSet2, funcSet2 = parentrole
                    funcSet1 = funcSet1.difference(funcSet2)
            # it means this role can be removed as their parentroles has contain all its functions .
            if len(funcSet1)==0:
                removes.append(i)
            else:
                # it means this role need be minimized to a new roles 
                roles[i] = (userSet1, funcSet1)  
            hierarchyMatrix[i] = np.zeros(len(hierarchyMatrix[i]))

        # it means the roles[i] has no more permission functions than any some roles 
        # but there exists other roles have more permission functions than roles[i]
        elif numOfparentroles == 0 and numOfchildroles >0:
            for j in range(len(hierarchyMatrix[:,i])):
                if hierarchyMatrix[j,i] == 1:
                    dfsReduceRecursive(roles, j)
        # it means the roles[i] has more permission functions than some roles 
        # and there exists other roles have more permission functions  than roles[i]
        elif numOfparentroles > 0 and numOfchildroles >0:
            userSet1, funcSet1 = roles[i]
            for j in range(len(hierarchyMatrix[i])):
                if hierarchyMatrix[i, j] == 1:
                    parentrole = roles[j]
                    userSet2, funcSet2 = parentrole
                    funcSet1 = funcSet1.difference(funcSet2)
            # it means this role can be removed as their parentroles has contain all its functions .
            # in this case, we need first to handle the role that has much more permission functions.
            for j in range(len(hierarchyMatrix[:,i])):
                if hierarchyMatrix[j,i] == 1:
                    dfsReduceRecursive(roles, j)
            
            # it means this role can be removed as their parentroles has contain all its functions .
            if len(funcSet1)==0:
                removes.append(i)
            else:
                # it means this role need be minimized to a new roles 
                roles[i] = (userSet1, funcSet1) 
            hierarchyMatrix[i] = np.zeros(len(hierarchyMatrix[i]))

def ReduceMain(roles):
    global hierarchyMatrix, removes
    hierarchyMatrix = None 
    removes = list() 
    buildRoleHierarchy(roles)
    for i in range(len(roles)):
        dfsReduceRecursive(roles, i)

    # print("removes: ", removes)
    removes = list(set(removes))
    removes.sort(reverse=True)
    [roles.pop(i) for i in removes]

    constant_roles = list()
    for role in roles:
        constant_roles.append((frozenset(role[0]), frozenset(role[1])))

    return constant_roles 

class GA_RM:
    def __init__(self, permissionMatrix, freqMatrix, simratio, \
        userLabels, userMap, generation, gene_encoding, address):
        self.userMap = userMap 
        self.userLabels = userLabels
        self.simratio = simratio
        # shufle the users for later sampling
        #jjjself.df = permissionMatrix.sample(n = permissionMatrix.shape[0])
        self.df = permissionMatrix.T 
        self.permissions = list(permissionMatrix.columns)
        self.users = list(permissionMatrix.index)
        self.R = self.df.to_numpy()
        # U: users, A: funcs
        self.A, self.U = self.R.shape 
        print(f"No.user: {self.U}; No.func: {self.A}")
        self.start = time.time()       
        
        self.G_DF = self.df
     
        self.G_A = self.A
        self.G_U = self.U
        self.freqMatrix = freqMatrix
        self.gene_encoding = gene_encoding
        self.Debug = False
        self.address = address 
        self.generation = generation

        self.verybasic_usergroups, self.UPA = self.createBasicLatticeRoles(self.users)
        self.basicRoles = ReduceMain(copy.copy(self.verybasic_usergroups))
        self.training_users = set()
        self.test_users = set()
    
    def translateLattice2Role(self, lattice):
        roles = []
        for function_set, user_set in lattice:
            if len(function_set) >0 and len(user_set)>0:
                roles.append((frozenset(user_set), frozenset([ func_str.replace("(","").replace(",)","").replace("'","") for func_str in function_set]))) 
        return roles  
    
    def createBasicLatticeRoles(self, users):
        df = self.G_DF.loc[:, list(map(int, users))]        
        # permissions
        objects = map(lambda id: str(id), df.index.tolist())
        # users
        properties = map(lambda id: str(id), df.columns.tolist())

        bools = list(df.fillna(False).astype(bool).itertuples(index=False, name=None))
        lattice = concepts.Context(objects, properties, bools)

        roles = self.translateLattice2Role(lattice.lattice)
        return roles, df.fillna(False).astype(bool)
      
    def getTrainingBasicRoles(self):
        return self.basicRoles, self.UPA

    def getTestingBasicRoles(self):
        return self.basicRoles, self.UPA
    
  
    # @lru_cache(maxsize=None)
    def getUserFunctionCount(self, user, method):
        return self.freqMatrix.loc[int(user), method]
    
    @lru_cache(maxsize=None)
    def getAFV(self, role):
            user_set, func_set =  role
            # Consider global function usage by the users of candidate roles
            union_functions = list(set(self.permissions))
            # initialize average frequency vector for each candidate roles
            n  = len(union_functions)
            AFV = np.zeros(n)
            for i in range(n):
                function = union_functions[i]
                # AFV[i] = np.sum([ self.getUserFunctionCount(user, function) for user in user_set])/len(user_set)
                AFV[i] = np.sum(self.freqMatrix.loc[list(map(int, user_set)), function].to_numpy())/len(user_set)
            return AFV
    
    @lru_cache(maxsize=None)
    def calcsimilarity(self, roleA, roleB):
            AFV_a = self.getAFV(roleA)
            AFV_b = self.getAFV(roleB)
                
            similarity = 1 - distance.cosine(AFV_a, AFV_b)
            if self.Debug:
                print(f"AFV_a {AFV_a}")
                print(f"AFV_b {AFV_b}")
                print(f"similarity {similarity} for {roleA[1]} vs {roleB[1]}")
            return similarity
 
    def miningWithGAWith1DRealChromosome(self):
        Debug = False
        if self.U < 1:
            self.roles = []
            return self.roles 
        if self.U == 1:
            self.roles = []
            self.roles.append(([0], set(self.permissions)))
            return  self.roles

        trainBasicRoles, trainUPA = self.getTrainingBasicRoles()
        testBasicRoles, testUPA = self.getTestingBasicRoles()

        report = PrettyTable()
        report.title = "Basic roles statistics (id, len(users), functions)"
        report.field_names = ["RoleId", "Users", "Functions"]
        for index in range(len(trainBasicRoles)):
            role = trainBasicRoles[index]
            users, functions = len(role[0]), list(role[1])
            report.add_row([index, users, functions])
        print(report)
        
        # 1D real value Genome.
        # chromosome = [r1, r2, ..., rn]
        def translateChromosome2Roles(chromosome):
            badmergecount = 0
            roles = []
            new_chromosome = list(map(int, chromosome))
            mergeGroups = dict()
            for val in new_chromosome:
                mergeGroups[val] = np.where(np.array(new_chromosome)== val)[0]
            for groupkey, basicRoleIndices in mergeGroups.items():
                roles.append([trainBasicRoles[index] for index in basicRoleIndices])
            return roles, badmergecount
        
        def calculateTwoMineCompositeRolesSimilarity(crole1, crole2):
            sumSimError = 0
            for role1 in crole1:
                simError = 0
                for role2 in crole2:
                    simError = max(simError,  self.calcsimilarity(role1, role2))
                sumSimError += simError
            for role1 in crole2:
                simError = 0
                for role2 in crole1:
                    simError = max(simError,  self.calcsimilarity(role1, role2))
                sumSimError += simError

            return sumSimError/(len(crole1)+len(crole2))
     
        def calculateRoleSimilarityError(finalroles):
            simError = 0
            n = len(finalroles)
            if n==1:
                return simError
            for i in range(n-1):
                for j in range(i+1, n):
                    if i==j:
                        continue
                    simError = max(simError, calculateTwoMineCompositeRolesSimilarity(finalroles[i], finalroles[j]) )
            return simError
                
        def getClosestRoleInRoleSet(sourceRole, roles):
            maxSimilarity = 0
            closestRole = None
            for i in range(len(roles)):
                    roleA = roles[i]
                    roleA_functions = set(itertools.chain.from_iterable([ childrole[1] for childrole in roles[i]]))
                    roleB = sourceRole
                    similarity = len(roleA_functions.intersection(roleB[1]))/len(roleA_functions.union(roleB[1]))      
                    if similarity > maxSimilarity:
                        maxSimilarity  = similarity
                        closestRole = roleA
            return closestRole
                
        def translateRoles2UPA(roles):
            matrix = np.zeros((len(self.permissions), len(self.users)))
            df = pd.DataFrame(data=matrix, index=self.permissions, columns=self.users)
            for role in roles:
                users, funcs = role
                df.loc[list(funcs), list(map(int, users))] = 1
            return df
        
        @lru_cache(maxsize=None)
        def getTestRoleL1Norm(role):
                users, funcs = role
                subTestUPA = testUPA.loc[:, list(map(int, users))]
                return np.count_nonzero(subTestUPA.to_numpy())
        
        @lru_cache(maxsize=None)
        def getDelta(predictedRole):
                users, funcs = predictedRole
                delta = len(users)*len(funcs) - np.count_nonzero(testUPA.loc[list(funcs), list(map(int, users))].to_numpy())
                return delta

        def calculateGeneralizationError(finalroles):
            predictedRoles = list()
            genError = 0
            counter = 0
            totalDelta = 0
            for role in testBasicRoles:
                closestRole = getClosestRoleInRoleSet(role, finalroles)
                if closestRole is None:
                    continue
                predictedRole =(role[0], frozenset(itertools.chain.from_iterable([childrole[1] for childrole in closestRole])))
                predictedRoles.append(predictedRole)
                testRoleL1Norm = getTestRoleL1Norm(role)
                delta = getDelta(predictedRole)
                totalDelta += delta
                error = delta/(testRoleL1Norm +  delta) 
                # error = delta/(len(role[0])*len(self.permissions)) 
                if error > 0:
                    genError += error 
                    counter += 1
            total_genError = 0
            if counter > 0:
                total_genError = genError/counter
            return total_genError
        
        @lru_cache(maxsize=None)
        def cached_eval_func(chromosome):
            score = 0.0
            finalroles, badmergecount = translateChromosome2Roles(chromosome)
            simErr = calculateRoleSimilarityError(finalroles)
            genErr = calculateGeneralizationError(finalroles)
            a = self.simratio
            b = 1 - a 
            score =  1 / (a * simErr + b * genErr + 0.001) 
            return score
            
        global eval_func
        def eval_func(chromosome):
            new_chromosome = list(map(int, chromosome))
            role_ids = sorted(list(set(new_chromosome)))
            new_chromosome = [ role_ids.index(_role_id) for _role_id in new_chromosome]
            # replace old chromosome with new chromosome
            for i in range(len(chromosome)):
                chromosome[i] = new_chromosome[i]
    
            return cached_eval_func(tuple(chromosome))

        def print_eval_func(chromosome):
            nonlocal Debug
            score = 0.0
            finalroles, badmergecount = translateChromosome2Roles(chromosome)
            simErr = calculateRoleSimilarityError(finalroles)
            genErr = calculateGeneralizationError(finalroles)
           
            a = self.simratio
            b = 1 - a 
            score = 1 / (a * simErr + b * genErr + 0.001) 
            finalroles = list(finalroles)
            
            returnroles = list()
            for role in finalroles:
                users = set(itertools.chain.from_iterable([ childrole[0] for childrole in role]))
                permissions = set(itertools.chain.from_iterable([ childrole[1] for childrole in role]))
                returnroles.append((users, permissions))
            # print(chromosome)
            logger.info(f"score: {score}, genErr: {genErr},  simErr: {simErr}, badmergecount: {badmergecount}")
            return score, genErr, simErr, returnroles, badmergecount 
                
                

        n = len(trainBasicRoles)
        assert n>1, "the number of basic roles must be greater than one"
        
        genome = G1DList.G1DList(n)
        genome.setParams(rangemin=0, rangemax=n)

        genome.initializator.set(Initializators.G1DListInitializatorReal)
        genome.mutator.set(Mutators.G1DListMutatorSwap)
        genome.mutator.add(Mutators.G1DListMutatorRealRange)
        genome.crossover.set(Crossovers.G1DListCrossoverSinglePoint) 
        genome.evaluator.set(eval_func)
          
        # ga = GSimpleGA.GSimpleGA(genome, seed=666)
        ga = GSimpleGA.GSimpleGA(genome, seed=2022)
        
        # Etilism ensures that best individuals will be carried to the next population (global optima)
        # Noted each new population would first be generated through selection, crossover and muation
        # Then the best indiv of previous generations will be compared to the current best indiv of the new population
        # Hereby, among them, the best indiv would be current etilism and will be put in the new population 
        # by replacing its best indiv
        ga.setElitism(True)
        ga.setElitismReplacement(1)
        ga.setSortType(Consts.sortType["scaled"])
        ga.selector.set(Selectors.GTournamentSelector)
        ga.internalPop.scaleMethod.set(Scaling.LinearScaling, weight=0.5)
        # ga.internalPop.scaleMethod.add(Scaling.BoltzmannScaling, weight=0.1)
        # ga.internalPop.scaleMethod.add(Scaling.ExponentialScaling, weight=0.1)
        # ga.internalPop.scaleMethod.add(Scaling.PowerLawScaling, weight=0.1)
        # ga.internalPop.scaleMethod.add(Scaling.SaturatedScaling, weight=0.1)
        # ga.internalPop.scaleMethod.add(Scaling.SigmaTruncScaling, weight=0.1)

        ga.setMutationRate(0.10)
        ga.setCrossoverRate(0.99)
        ga.setPopulationSize(100)
        ga.setGenerations(self.generation)
        
        ga.setMultiProcessing(True, full_copy=False, max_processes = 10)
        
        ga.evolve(freq_stats=100)
        bestindividual = ga.bestIndividual()
        #print(bestindividual)
        Debug = False
        score, genErr, simErr, bestRoles, badmergecount  = print_eval_func(bestindividual)
        Debug = False
        print(f"best role number: {len(bestRoles)}")
        no = 0
        for role in bestRoles:
            print(f"Role#{no}:{role[1]}")
            no += 1
        self.roles = bestRoles
        self.score, self.genErr, self.simErr, self.badMergeCount = (score, genErr, simErr, badmergecount)   
        return self.roles

    def process(self):
        roles = self.miningWithGAWith1DRealChromosome()
        newroles = list()
        for role in roles:
            roleuser = set([ self.userMap[int(user)] for user in role[0]]) 
            newroles.append((frozenset(roleuser), frozenset(role[1])))
        return newroles

from .staticAnalyzer import getRWofContract

def DeriveRolePermissionPolicy(reads, reads2, writes):
    
    def getWritefuncs(role, datas):
        priviledge_funcs = set() 
        for func in writes:
            if 0 == len(set(datas).intersection(writes[func].difference(reads2[func]))):
                continue
            else:
                priviledge_funcs.add(func)
        return priviledge_funcs.intersection(set(role[1]))

    def createInformationSecurityPolicy(mined_roles):
        try:
            if reads is None or writes is None:
                raise Exception("reads and writes is not set!")
        except:
            return set()
        dataR = list()
        dataW = list()
        observed_functions = set(itertools.chain.from_iterable([mined_role[1] for mined_role in mined_roles]))
        roles = list(mined_roles)
        for i in range(len(roles)):
            role_reads = set(itertools.chain.from_iterable([reads[func] for func in roles[i][1] if func in reads ]))
            role_writes = set(itertools.chain.from_iterable([writes[func].difference(reads[func]) for func in roles[i][1] if func in writes]))
            # role_writes  = role_writes.difference(role_reads)
            role_writes  = role_writes
            dataR.append(role_reads)
            dataW.append(role_writes)
        
        n = len(roles)
        newDataW = copy.deepcopy(dataW)
        for i in range(len(roles)):
            newDataW[i] = dataW[i] - (set(itertools.chain.from_iterable(dataW[:i])) - set(itertools.chain.from_iterable(dataW[i+1:])))
        
        dataW = newDataW

        securityLattice = np.zeros((n, n))
        for i in range(n):
            for j in range(i+1, n):
                if set(dataW[i]).issubset(set(dataW[j])) and len(set(dataW[i])) < len(set(dataW[j])):
                    securityLattice[i][j] = -1 
                    securityLattice[j][i] = 1
                elif set(dataW[i]).issuperset(set(dataW[i])) and len(set(dataW[j])) < len(set(dataW[i])):
                    securityLattice[i][j] = 1 
                    securityLattice[j][i] = -1
        
        securityPolicies = set()
        for i in range(n):
            for j in range(i+1, n):
                if securityLattice[i][j] == 1:
                    high_security_role = roles[i] 
                    # integrity 
                    securityPolicies.add(tuple([high_security_role, frozenset(dataW[i].difference(dataW[j])), frozenset(getWritefuncs(high_security_role, dataW[i].difference(dataW[j])))]))
                elif securityLattice[i][j] == -1:
                    high_security_role = roles[j] 
                    # integrity 
                    securityPolicies.add(tuple([high_security_role, frozenset(dataW[j].difference(dataW[i])), frozenset(getWritefuncs(high_security_role, dataW[j].difference(dataW[i])))]))
                elif securityLattice[i][j] == 0:
                    # separation of duty 
                    role1, role2 = roles[i], roles[j]
                    if len(frozenset(dataW[i].difference(dataW[j])))>0:
                        securityPolicies.add(tuple([role1, frozenset(dataW[i].difference(dataW[j])), frozenset(getWritefuncs(role1, dataW[i].difference(dataW[j])))]))
                    if len( frozenset(dataW[j].difference(dataW[i])))>0:
                        securityPolicies.add(tuple([role2, frozenset(dataW[j].difference(dataW[i])), frozenset(getWritefuncs(role2, dataW[j].difference(dataW[i])))]))
        
        return securityPolicies

        
    return createInformationSecurityPolicy

def runRoleMiningForSingleContract(address, contractName, contractAbi, reads, reads2, writes, generation, simratio, workdir):
        print(address, contractName)
        start = time.time()
        observed_methods, verybasic_userGroups, mined_roles = lightweightrolemining(address=address, abi = contractAbi, gene_encoding="real", generation = generation, simratio=simratio, workdir=workdir)
        end = time.time()
        print("Time cost:", end-start)

        createInformationSecurityPolicy = \
            DeriveRolePermissionPolicy(reads=reads, reads2=reads2, writes=writes)
        security_policy = createInformationSecurityPolicy(mined_roles=mined_roles)

        print("Security Policy:")
        counter = 0
        for policy in security_policy:
            role, separation_data, separation_priviledged_functions = policy
            role = role[1] if isinstance(role, tuple) else role
            print(f"Policy#{counter}: {' '.join(role)} -> {' '.join(separation_data)} via functions {' '.join(separation_priviledged_functions)}")
            counter += 1

        return observed_methods, func_mappings, security_policy, [] 