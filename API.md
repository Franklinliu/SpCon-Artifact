   
# Module `spcon` 

    
## Sub-modules

* [spcon.query](#spcon.query)
* [spcon.roleminer](#spcon.roleminer)
* [spcon.spconbenchmarkminer](#spcon.spconbenchmarkminer)
* [spcon.staticAnalyzer](#spcon.staticAnalyzer)
* [spcon.symExec](#spcon.symExec)






    
# Module `spcon.query` 






    
## Functions


    
### Function `main_collecttransaction_history` 




>     def main_collecttransaction_history(
>         address,
>         workdir='./',
>         date='latest'
>     )




    
### Function `run_query` 




>     def run_query(
>         query,
>         variables
>     )







    
# Module `spcon.roleminer` 






    
## Functions


    
### Function `DeriveRolePermissionPolicy` 




>     def DeriveRolePermissionPolicy(
>         reads,
>         reads2,
>         writes
>     )




    
### Function `ReduceMain` 




>     def ReduceMain(
>         roles
>     )




    
### Function `buildRoleHierarchy` 




>     def buildRoleHierarchy(
>         roles
>     )




    
### Function `dfsReduceRecursive` 




>     def dfsReduceRecursive(
>         roles,
>         i
>     )




    
### Function `getABI_file` 




>     def getABI_file(
>         directory
>     )




    
### Function `getABIfunction_signature_mapping` 




>     def getABIfunction_signature_mapping(
>         abi
>     )




    
### Function `getABIfunctions` 




>     def getABIfunctions(
>         abi_file
>     )




    
### Function `getMethodName` 




>     def getMethodName(
>         hex_signature
>     )




    
### Function `lightweightrolemining` 




>     def lightweightrolemining(
>         address,
>         abi,
>         gene_encoding,
>         generation,
>         simratio,
>         workdir
>     )




    
### Function `runRoleMiningForSingleContract` 




>     def runRoleMiningForSingleContract(
>         address,
>         contractName,
>         contractAbi,
>         reads,
>         reads2,
>         writes,
>         generation,
>         simratio,
>         workdir
>     )





    
## Classes


    
### Class `GA_RM` 




>     class GA_RM(
>         permissionMatrix,
>         freqMatrix,
>         simratio,
>         userLabels,
>         userMap,
>         generation,
>         gene_encoding,
>         address
>     )










    
#### Methods


    
##### Method `calcsimilarity` 




>     def calcsimilarity(
>         self,
>         roleA,
>         roleB
>     )




    
##### Method `createBasicLatticeRoles` 




>     def createBasicLatticeRoles(
>         self,
>         users
>     )




    
##### Method `getAFV` 




>     def getAFV(
>         self,
>         role
>     )




    
##### Method `getTestingBasicRoles` 




>     def getTestingBasicRoles(
>         self
>     )




    
##### Method `getTrainingBasicRoles` 




>     def getTrainingBasicRoles(
>         self
>     )




    
##### Method `getUserFunctionCount` 




>     def getUserFunctionCount(
>         self,
>         user,
>         method
>     )




    
##### Method `miningWithGAWith1DRealChromosome` 




>     def miningWithGAWith1DRealChromosome(
>         self
>     )




    
##### Method `process` 




>     def process(
>         self
>     )




    
##### Method `translateLattice2Role` 




>     def translateLattice2Role(
>         self,
>         lattice
>     )






    
# Module `spcon.spconbenchmarkminer` 






    
## Functions


    
### Function `ReduceMain` 




>     def ReduceMain(
>         roles
>     )




    
### Function `appendExcelRow` 




>     def appendExcelRow(
>         ws,
>         n,
>         simratio,
>         address,
>         timecost,
>         roleNumber,
>         mined_roles,
>         labledroles,
>         groundtruth_roles,
>         number_ratio,
>         role_sim10_1,
>         role_sim10_2,
>         role_sim05_1,
>         role_sim05_2,
>         role_sim025_1,
>         role_sim025_2,
>         role_sim00_1,
>         role_sim00_2
>     )




    
### Function `buildRoleHierarchy` 




>     def buildRoleHierarchy(
>         roles
>     )




    
### Function `compareRoleSets` 




>     def compareRoleSets(
>         mined_roles,
>         deployed_roles,
>         t=1.0
>     )




    
### Function `dfsReduceRecursive` 




>     def dfsReduceRecursive(
>         roles,
>         i
>     )




    
### Function `getABI_file` 




>     def getABI_file(
>         directory
>     )




    
### Function `getABIfunction_signature_mapping` 




>     def getABIfunction_signature_mapping(
>         abi_file
>     )




    
### Function `getABIfunctions` 




>     def getABIfunctions(
>         abi_file
>     )




    
### Function `getMethodName` 




>     def getMethodName(
>         hex_signature
>     )




    
### Function `getSetOfSimilarityMetrics` 




>     def getSetOfSimilarityMetrics(
>         mined_roles,
>         deployed_roles
>     )




    
### Function `initExcelHead` 




>     def initExcelHead(
>         ws_result
>     )




    
### Function `jaccard_func` 




>     def jaccard_func(
>         set1,
>         set2
>     )




    
### Function `label_func` 




>     def label_func(
>         role_permission_functions,
>         other_permission_functions,
>         ABIfunctions
>     )




    
### Function `lightweightrolemining` 




>     def lightweightrolemining(
>         address,
>         gene_encoding,
>         simratio,
>         workdir
>     )




    
### Function `main` 




>     def main()




    
### Function `roleset_roleset_jaccard_func_old_donot_purse_one2one` 




>     def roleset_roleset_jaccard_func_old_donot_purse_one2one(
>         roleset1,
>         roleset2,
>         t=1
>     )





    
## Classes


    
### Class `GA_RM` 




>     class GA_RM(
>         permissionMatrix,
>         freqMatrix,
>         simratio,
>         userLabels,
>         userMap,
>         gene_encoding,
>         address
>     )










    
#### Methods


    
##### Method `calcsimilarity` 




>     def calcsimilarity(
>         self,
>         roleA,
>         roleB
>     )




    
##### Method `createBasicLatticeRoles` 




>     def createBasicLatticeRoles(
>         self,
>         users
>     )




    
##### Method `getAFV` 




>     def getAFV(
>         self,
>         role
>     )




    
##### Method `getTestingBasicRoles` 




>     def getTestingBasicRoles(
>         self
>     )




    
##### Method `getTrainingBasicRoles` 




>     def getTrainingBasicRoles(
>         self
>     )




    
##### Method `getUserFunctionCount` 




>     def getUserFunctionCount(
>         self,
>         user,
>         method
>     )




    
##### Method `miningWithGAWith1DRealChromosome` 




>     def miningWithGAWith1DRealChromosome(
>         self
>     )




    
##### Method `process` 




>     def process(
>         self
>     )




    
##### Method `translateLattice2Role` 




>     def translateLattice2Role(
>         self,
>         lattice
>     )






    
# Module `spcon.staticAnalyzer` 






    
## Functions


    
### Function `getRWofContract` 




>     def getRWofContract(
>         address
>     )




    
### Function `test` 




>     def test()





    
## Classes


    
### Class `Analyzer` 




>     class Analyzer










    
#### Methods


    
##### Method `analyze` 




>     def analyze(
>         self,
>         address
>     )




    
##### Method `controldependency` 




>     def controldependency(
>         self,
>         function
>     )






    
# Module `spcon.symExec` 






    
## Functions


    
### Function `BlockchainInfo` 




>     def BlockchainInfo(
>         *args,
>         **kwargs
>     )




    
### Function `SymExecEVM` 




>     def SymExecEVM(
>         *args,
>         **kwargs
>     )




    
### Function `ethGetCode` 




>     def ethGetCode(
>         state,
>         address
>     )




    
### Function `ethGetStorageAt` 




>     def ethGetStorageAt(
>         state,
>         storage_address,
>         offset
>     )




    
### Function `eth_GetBalanceOf` 




>     def eth_GetBalanceOf()




    
### Function `eth_GetCode` 




>     def eth_GetCode()




    
### Function `getAPIData` 




>     def getAPIData(
>         url
>     )




    
### Function `getPage` 




>     def getPage(
>         url
>     )




    
### Function `getPage0` 




>     def getPage0(
>         url
>     )




    
### Function `getPage1` 




>     def getPage1(
>         url
>     )




    
### Function `getPage2` 




>     def getPage2(
>         url
>     )




    
### Function `setContractAccount` 




>     def setContractAccount(
>         _targetrealworldaddress,
>         _contract_account
>     )




    
### Function `setDisable` 




>     def setDisable()




    
### Function `setEnable` 




>     def setEnable()




    
### Function `singleton` 




>     def singleton(
>         class_
>     )




    
### Function `wraper` 




>     def wraper(
>         state,
>         storage_address,
>         offset
>     )





    
## Classes


    
### Class `CodeMonitor` 




>     class CodeMonitor


This just aborts explorations that are too deep


    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_evm_read_code_callback` 




>     def did_evm_read_code_callback(
>         self,
>         state,
>         address,
>         offset,
>         size,
>         *args
>     )




    
##### Method `will_evm_read_code_callback` 




>     def will_evm_read_code_callback(
>         self,
>         state,
>         address,
>         *args
>     )




    
### Class `ForkMonitor` 




>     class ForkMonitor





    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_fork_state_callback` 




>     def did_fork_state_callback(
>         self,
>         state,
>         expression,
>         solutions,
>         policy,
>         children
>     )




    
### Class `StorageRWMonitor` 




>     class StorageRWMonitor


This just aborts explorations that are too deep


    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_evm_read_storage_callback` 




>     def did_evm_read_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         *args
>     )




    
##### Method `will_evm_read_storage_callback` 




>     def will_evm_read_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         *args
>     )



    
##### Method `will_evm_write_storage_callback` 


>     def will_evm_write_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         value,
>         *args
>     )
