import time
import random
import traceback
import sys
from typing import Sequence
from manticore.ethereum import  ManticoreEVM
from manticore.ethereum.detectors import DetectDelegatecall, DetectExternalCallAndLeak, DetectSuicidal
from manticore.exceptions import NoAliveStates
from manticore.core.plugin import Plugin
import manticore.utils as utils 

from functools import wraps
import os
import requests 
import json
# import socket
# import socks 
# import cloudscraper
import logging, coloredlogs
from timeout_decorator import timeout_decorator
from spcontoolplus.crawler.crawler import getAPIData
################ Script #######################

# default_factory = logging.getLogRecordFactory()
# logfmt = "%(asctime)s: [%(process)d] %(name)s:%(levelname)s %(message)s"
# handler = logging.StreamHandler(sys.stdout)
# formatter = logging.Formatter(logfmt)
# handler.setFormatter(formatter)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

coloredlogs.install(level="INFO", logger = logger)

def singleton(class_):
    instances = {}
    def getinstance(*args, **kwargs):
        if class_ not in instances:
            instances[class_] = class_(*args, **kwargs)
        return instances[class_]
    return getinstance


apikey = "URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ"
targetrealworldaddress = "0x0B84EdEcb764299cA228E75BBcaDd6eBFee91d4e"
contract_account = None

Standard_Storages = dict()

@singleton   
class BlockchainInfo(object):
    def __init__(self, codelogfile = "./blockchaincode.json",  storagelogfile = "./blockchainstorage.json", balancelogfile="./blockchainbalance.json"):
        self.codelogfile = codelogfile
        self.storagelogfile = storagelogfile
        self.balancelogfile = balancelogfile
        self.cachedCode = dict()
        self.cachedStorage = dict()
        self.cachedBalance = dict()
        self.loadStorage()
        self.loadCode()
        self.loadBalance()
        self.clearStorageSeen()
        self.saveCode()
        self.saveStorage()
        self.saveBalance()

    def report(self):
        # print(f"report logfile: {self.logfile}")
        self.loadStorage()
        self.loadCode()

        logger.debug(f"report cachedStorage: {self.cachedStorage} having keys: {self.cachedStorage.keys()}\n")
    
    def loadBalance(self):
        if os.path.exists(self.balancelogfile):
            try:
                with open(self.balancelogfile, "r") as fp:
                    self.cachedBalance = json.load(fp) 
            except json.decoder.JSONDecodeError as e:
                os.system(f"rm {self.balancelogfile}")
                self.cachedBalance = dict()
            except:
                os.system(f"rm {self.balancelogfile}")
                self.cachedBalance = dict()
    
    def saveBalance(self):
        # print(f"report logfile: {self.logfile}")
        with open(self.balancelogfile, "w") as fp:
            json.dump(self.cachedBalance, fp)

    def loadCode(self):
        if os.path.exists(self.codelogfile):
            try:
                with open(self.codelogfile, "r") as fp:
                    self.cachedCode = json.load(fp)
            except json.decoder.JSONDecodeError as e:
                os.system(f"rm {self.codelogfile}")
                self.cachedCode = dict()
            except:
                os.system(f"rm {self.codelogfile}")
                self.cachedCode = dict()

    def saveCode(self):
        # print(f"report logfile: {self.logfile}")
        with open(self.codelogfile, "w") as fp:
            json.dump(self.cachedCode, fp)
    
    def loadStorage(self):
        if os.path.exists(self.storagelogfile):
            try:
                with open(self.storagelogfile, "r") as fp:
                    self.cachedStorage = json.load(fp)
            except json.decoder.JSONDecodeError as e:
                os.system(f"rm {self.storagelogfile}")
                self.cachedStorage = dict()
            except:
                os.system(f"rm {self.storagelogfile}")
                self.cachedStorage = dict()

    def saveStorage(self):
        # print(f"report logfile: {self.logfile}")
        with open(self.storagelogfile, "w") as fp:
            json.dump(self.cachedStorage, fp)
        
    def clearStorageSeen(self):
        for contract_address in self.cachedStorage:
            for slot in self.cachedStorage[contract_address]:
                if "seen" in self.cachedStorage[contract_address][slot]:
                    self.cachedStorage[contract_address][slot]["seen"] = list()
   
    def __call__(self, func):
        global wraper
        global Standard_Storages
        @wraps(func)
        def wraper(*args, **kwargs): 
            global contract_account 
            global targetrealworldaddress

            self.loadStorage()
            self.loadCode()
          
            # print(f"start cachedStorage: {self.cachedStorage} at address {hex(id(self.cachedStorage))}")
            if func.__name__ == "ethGetCode":
                if len(kwargs) == 0:
                    assert len(args) == 2, f"{func.__name__} needs two arguments but got {len(args)} "
                    state, contract_address = args
                    world = state.platform
                else:
                    assert len(args) == 0
                    assert len(kwargs) == 2, f"{func.__name__} needs two arguments but got {len(kwargs)} "
                    contract_address = kwargs["address"]
                    state = kwargs["state"]
                    world = state.platform
               
                contractAddressHexStr = hex(contract_address)
                if contractAddressHexStr in self.cachedCode:
                    code = self.cachedCode[contractAddressHexStr]
                    if contract_address not in world.accounts:
                        world.create_account(contract_address)
                    world.set_code(contract_address,  bytes() if len(code)==0 else bytes.fromhex(code))
                else:
                    code =  func(*args, **kwargs)
                    self.cachedCode[contractAddressHexStr] =  code 
                    if contract_address not in world.accounts:
                        world.create_account(contract_address)
                    world.set_code(contract_address, bytes() if len(code)==0 else bytes.fromhex(code))
                
                self.saveCode()
                return self.cachedCode[contractAddressHexStr]
            
            elif func.__name__ == "ethGetStorageAt":
                
                if len(kwargs) == 0:
                    assert len(args) == 3, f"{func.__name__} needs three arguments but got {len(args)} "
                    state, storage_address, offset = args
                else:
                    assert len(args) == 0
                    assert len(kwargs) == 3, f"{func.__name__} needs three arguments but got {len(kwargs)} "
                    state = kwargs["state"]
                    offset = kwargs["offset"]
                    storage_address = kwargs["storage_address"]
                
                # print(f"{storage_address in self.cachedStorage[state.id]}")
                
                world = state.platform

                if hex(contract_account.address) == hex(storage_address):
                    contract_address =  targetrealworldaddress
                else:
                    contract_address =  str(hex(storage_address))


                if contract_address not in self.cachedStorage:
                    self.cachedStorage[contract_address] = dict()

                if isinstance(offset, int):
                    offsethexstr = str(hex(offset))
                    if offsethexstr not in self.cachedStorage[contract_address]:
                        self.cachedStorage[contract_address][offsethexstr] = dict()
                        # self.cachedStorage[contract_address][offsethexstr]["value"] = None
                        self.cachedStorage[contract_address][offsethexstr]["seen"] = list()

                    if state.id not in self.cachedStorage[contract_address][offsethexstr]["seen"]:
                        if "value" in self.cachedStorage[contract_address][offsethexstr]:
                            logger.debug(f"cached {storage_address}({offset}): {self.cachedStorage[contract_address][offsethexstr]}")
                            value = self.cachedStorage[contract_address][offsethexstr]["value"]
                        else:
                            value =  func(*args, **kwargs)
                            assert isinstance(value, int)
                            if storage_address in Standard_Storages:
                                for _offset in Standard_Storages[storage_address]:
                                    if _offset == offset:
                                        value = Standard_Storages[storage_address][_offset]
                            self.cachedStorage[contract_address][offsethexstr]["value"] = value
                        self.cachedStorage[contract_address][offsethexstr]["seen"].append(state.id)
                        world.set_storage_data(storage_address, offset, value)
                        logger.debug(f"initialize {storage_address}({offset}): {world.get_storage_data(storage_address, offset)}")
                    
                    self.saveStorage()
                    # print(f"end cachedStorage: {self.cachedStorage}")
                    return world.get_storage_data(storage_address, offset)
        return wraper

@BlockchainInfo()
def ethGetCode(state, address):
    global targetrealworldaddress
    code = "" 
    eth_getCode = "https://api.etherscan.io/api?module=proxy&action=eth_getCode&address={0}&tag=latest&apikey={1}".format(targetrealworldaddress if contract_account==address else hex(address), apikey)
    
    try:
        code = getAPIData(eth_getCode)
        # print(f"code: {code}")
        if code.startswith("0x"):
            code = code[2:]
    except:
        pass
    # if len(code) == 0:
    #     return bytes()
    # return bytes.fromhex(code) 
    return code

@BlockchainInfo()
def ethGetStorageAt(state, storage_address, offset):
    global apikey
    global targetrealworldaddress
    global contract_account
    VALUE = "0x0"
    try:
        eth_getStorageAt = "https://api.etherscan.io/api?module=proxy&action=eth_getStorageAt&address={0}&position={1}&tag=latest&apikey={2}".format(targetrealworldaddress if contract_account==storage_address else hex(storage_address), hex(offset), apikey)
        print(eth_getStorageAt)
        value = getAPIData(eth_getStorageAt)
        return int(value, 16)
    except:
        return int(VALUE, 16)
    # print(f"value: {value}, {bytearray.fromhex(value[2:])}")
    # return 100
   

def eth_GetCode():
    global targetrealworldaddress

    if targetrealworldaddress in BlockchainInfo().cachedCode:
        return bytes.fromhex(BlockchainInfo().cachedCode[targetrealworldaddress])
   
    eth_getCode = "https://api.etherscan.io/api?module=proxy&action=eth_getCode&address={0}&tag=latest&apikey={1}".format(targetrealworldaddress, apikey)
    
    try:
       
        code = getAPIData(eth_getCode)
        # print(f"code: {code}")
        if code.startswith("0x"):
            code = code[2:]
        else:
            code = ""
        BlockchainInfo().cachedCode[targetrealworldaddress] = code
        BlockchainInfo().saveCode()
    except:
        code = "" 

    if len(code) == 0:
        return bytes()
    return bytes.fromhex(code) 

def eth_GetBalanceOf():
    global apikey
    global targetrealworldaddress
    global contract_account
    if targetrealworldaddress in BlockchainInfo().cachedBalance:
        return int(BlockchainInfo().cachedBalance[targetrealworldaddress], 16)
   
    VALUE = "0x0" 
    try:
        eth_getBalanceOf = "https://api.etherscan.io/api?module=account&action=balance&address={0}&tag=latest&apikey={1}".format(targetrealworldaddress, apikey)
        print(eth_getBalanceOf)
        value = getAPIData(eth_getBalanceOf)
        logger.debug(value)
        
        BlockchainInfo().cachedBalance[targetrealworldaddress] = value
        BlockchainInfo().saveBalance()

        return int(value, 16)
    except:
        return int(VALUE, 16)
    # print(f"value: {value}, {bytearray.fromhex(value[2:])}")

EnableFlag = False 

class ForkMonitor(Plugin):
    def did_fork_state_callback(self, state, expression, solutions, policy, children ):

        logger.debug(
            "did_fork_state %r %r %r %r %r" % (state, expression, solutions, policy,children)
        )
        storagelogfile = "./blockchainstorage.json"
        cachedStorage = None 
        with open(storagelogfile, "r") as fp:
            cachedStorage = json.load(fp)
            for storage_address in cachedStorage:
                for slot in cachedStorage[storage_address]:
                    if state.id in cachedStorage[storage_address][slot]["seen"]:
                        # [cachedStorage[storage_address][slot]["seen"].append(child) for child in children]
                        cachedStorage[storage_address][slot]["seen"].extend(set(children)) 
        with open(storagelogfile, "w") as fp:
            json.dump(cachedStorage, fp)


class StorageRWMonitor(Plugin):
    """ This just aborts explorations that are too deep """

    def will_evm_read_storage_callback(self, state, storage_address, offset, *args):
        global EnableFlag
        # print("will_evm_read_storage_callback")
        if EnableFlag:
            with self.manticore.locked_context("seen_storager", dict) as reps:
                logger.debug(f"will read {storage_address}({offset})")
                try:
                    ethGetStorageAt(state, storage_address, offset)
                except OSError as e:
                    print(e)
                    pass 
                except:
                    pass 
                # reps.clear()
       
               
    def did_evm_read_storage_callback(self, state, storage_address, offset, *args):
        global EnableFlag
        # print("did_evm_read_storage_callback")
        if EnableFlag:
            world = state.platform
            
            with self.manticore.locked_context("seen_storager", dict) as reps:
                logger.debug(f"did read {storage_address}({offset}): {world.get_storage_data(storage_address, offset)}\n")
                reps.clear()

    def will_evm_write_storage_callback(self, state, storage_address, offset, value, *args):
        global EnableFlag, Standard_Storages
        # print("will_evm_write_storage_callback")
        if EnableFlag:
            world = state.platform
            if storage_address not in Standard_Storages:
                Standard_Storages[storage_address] = dict()
            if isinstance(offset, int):
                Standard_Storages[storage_address][offset] = value
            with self.manticore.locked_context("seen_storager", dict) as reps:
                logger.debug(f"will write {storage_address}({offset}): {value}\n")
                reps.clear()

class CodeMonitor(Plugin):
    """ This just aborts explorations that are too deep """

    def will_evm_read_code_callback(self, state, address, *args):
        global EnableFlag
        if EnableFlag:
            world = state.platform
            with self.manticore.locked_context("seen_codemonitor", dict) as reps:
                if address not in world.accounts or not world.has_code(address):
                # has_code = world.has_code(address)
                # if not has_code:
                    try:
                        logger.debug(f"will read code of contract {hex(address)}")
                        ethGetCode(state, address)
                    except:
                        pass 
                reps.clear()

    def did_evm_read_code_callback(self, state, address, offset, size, *args):
        global EnableFlag
        if EnableFlag:
            pass


def setEnable():
    global EnableFlag
    EnableFlag = True 

def setDisable():
    global EnableFlag
    EnableFlag = False 


def setContractAccount(_targetrealworldaddress, _contract_account):
    global targetrealworldaddress, contract_account
    contract_account = _contract_account
    targetrealworldaddress = _targetrealworldaddress

@singleton
class SymExecEVM():
    def __init__(self, *args,**kwargs) -> None:
        # m = ManticoreEVM()
        # m.verbosity(5)

        # m.register_plugin(StorageRWMonitor())
        # m.register_plugin(CodeMonitor())
        # m.register_plugin(ForkMonitor())

        # # add detector for vulnerable pattern detection
        # m.register_detector(DetectDelegatecall())
        # m.register_detector(DetectExternalCallAndLeak())
        # m.register_detector(DetectSuicidal())
        # self.m = m 
        # self.randomuser = None 
        pass 

    def symCreateContractAccount(self, file, constructorargs, contract, EthereumAddress):
        global contract_account
        global targetrealworldaddress
        global Standard_Storages
        
        Standard_Storages = dict()
        BlockchainInfo().clearStorageSeen()
        BlockchainInfo().saveStorage()
        targetrealworldaddress = EthereumAddress
        m = ManticoreEVM()
        utils.log.set_verbosity(1)

        m.register_plugin(StorageRWMonitor())
        m.register_plugin(CodeMonitor())
        m.register_plugin(ForkMonitor())

        # add detector for vulnerable pattern detection
        m.register_detector(DetectDelegatecall())
        m.register_detector(DetectExternalCallAndLeak())
        m.register_detector(DetectSuicidal())
        self.m = m 
        self.randomuser = None 
        self.accounts = dict()
        setDisable()
    
        with open(file) as fd:
            self.source_code = fd.read()
        self.contract = contract
        owner_account = self.m.create_account(balance=100000000000000, address= int("0xCeffee753b42bda1bcfa682f29685e2fd6729016", 16))
        self.accounts["0xCeffee753b42bda1bcfa682f29685e2fd6729016"] = owner_account
       
        attacker_account = self.m.create_account(balance=1000000000000, address= int("0xC0ffee753b42bda1bcfa682f29685e2fd6729016", 16))
        self.accounts["0xC0ffee753b42bda1bcfa682f29685e2fd6729016"] = attacker_account

        try:
            try:
                contract_account = self.m.solidity_create_contract(self.source_code, args = constructorargs, contract_name=self.contract, owner=owner_account)
                # contract_account = self.m.solidity_create_contract_stub(self.source_code, address = int(targetrealworldaddress, 16), contract_name=self.contract, owner=owner_account, code=eth_GetCode(), balance=eth_GetBalanceOf())
            except:
                compile_args = dict(compile_remove_metadata=True, \
                etherscan_api_key = "URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ")
                contract_account = self.m.solidity_create_contract_stub(targetrealworldaddress, address = int(targetrealworldaddress, 16), contract_name=self.contract, owner=owner_account, code=eth_GetCode(), balance=eth_GetBalanceOf(), compile_args=compile_args)
            assert contract_account is not None
        except:
            traceback.print_exc()
            raise NoAliveStates

        logger.debug(f"symbolic contract_account: {hex(contract_account.address)}")

        self.contract_account = contract_account
        logger.debug(f"current ready states: {self.m.count_ready_states()}")
        if self.m.count_ready_states() == 0:
            raise NoAliveStates
        
        setEnable()

        self.owner_account =owner_account
        self.attacker_account = attacker_account

        self.m.clear_terminated_states()

    # @typesList: dict[bytes4 -> (func_name, func_full_name)]
    @timeout_decorator.timeout(60)
    def symExec(self, unauthorizedusers, func, func_mappings):
        assert self.m.count_ready_states() >= 1, "No ready states are available"
        typesList = list()
        for bytes4 in func_mappings:
            func_name, func_full_name = func_mappings[bytes4]
            if func == func_name:
                typesList.append(func_full_name)

        if len(typesList) > 1:
            func_sig = typesList[random.randint(0, len(typesList)-1)]
        else:
            func_sig = typesList[0]
        types = func_sig.split("(")[1].split(")")[0].split(",")
        signature = f"({','.join(types)})"
        logger.info(f"SymExecEVM().symExec: {func_sig}")
        
        if self.randomuser is None:
            if unauthorizedusers:
                users = unauthorizedusers 
                randomuser = list(users)[random.randint(0, len(users)-1)]
                if randomuser in self.accounts.keys():
                    acc = self.accounts[randomuser]
                else:
                    acc = self.m.create_account(balance=1000000000000, address=int(randomuser, 16))
                    self.accounts[randomuser] = acc 
                randomuser = acc 
            else:
                randomuser = self.attacker_account
            # self.randomuser = randomuser
            self.randomuser = randomuser
        
        logger.info(f"attacker: {hex(self.randomuser.address)}")
        symbolicValue = 0
        symbolicArguments = self.m.make_symbolic_arguments(f"({','.join(types)})")
        # print(f"symbolicArguments: {symbolicArguments}")
        if len(symbolicArguments) > 0:
            execution = f'''self.contract_account.{func}(*symbolicArguments, caller=self.randomuser, value = symbolicValue, signature = signature)'''
        else:
            execution = f'''self.contract_account.{func}(caller=self.randomuser, value = symbolicValue, signature = signature)'''
        
        logger.debug(execution)
        with self.m.kill_timeout(60):
            eval(execution)
        logger.info(f"transaction status: {'success' if self.m.count_ready_states()>0 else 'false'}")
        logger.debug(f"current ready states: {self.m.count_ready_states()}")
        if self.m.count_ready_states() == 0:
            raise NoAliveStates

    @staticmethod
    @timeout_decorator.timeout(5*60)
    def fuzzing(file, constructorargs, contract, EthereumAddress, separation_policies, integrity_policies, all_accessed_functions, typesListofFuncs, reads, reads2, writes):
        start = time.time()
        if not os.path.exists(file):
            logger.error(f"unfounded file or folder: {file} ")
            return 
        attack_test_sequences = list()
        safePrivilegeFlag = True
        unprotected_pfs = set()
        K = 2
        def write2Exploit(timecost):
            with open("./exploit.txt", "a+") as fw:
                fw.write(f">>>{contract}-{EthereumAddress}:\n")
                for ele in attack_test_sequences:
                    data, attack_test_sequence = ele 
                    datastr = "{"+" ".join(data)+"}"
                    seqstr = " ".join(attack_test_sequence)
                    fw.write(f"{datastr}: {seqstr}\n") 
                fw.write(f"Testing time: {timecost}\n") 
                fw.write("<<<\n")
        def getDependentFuncs(f):
            nonlocal reads, writes
            dfuncs = list()
            freads, fwrites = list(), list()
            if f in reads:
                freads = reads[f]
            if f in writes:
                fwrites = writes[f]
            # freads, fwrites = reads[f], writes[f]
            for func in writes:
                if func == f:
                    continue
                funcreads, funcwrites = list(), list()
                if func in reads:
                    funcreads = reads[func]
                if func in writes:
                    funcwrites = writes[func]
                    
                if len(set(freads).intersection(funcwrites))>0:
                    if func!="constructor":
                        dfuncs.append(func)
            return dfuncs

        def symExec(unauthorizedusers, S):
            status = False 
            try:
                SymExecEVM().symCreateContractAccount(file=file, constructorargs = constructorargs, contract=contract, EthereumAddress=EthereumAddress)
            except:
                traceback.print_exc()
                logger.critical(f"{contract}-{EthereumAddress} cannot be deployed using manticore")
                exit(-1)
                return status 
            try:
                logger.info(f"Test Sequence: {list(reversed(S))}")
                for i in range(len(S)-1, -1, -1):
                    func = S[i]
                    SymExecEVM().symExec(unauthorizedusers, func, func_mappings=typesListofFuncs)
                status = True
            except NoAliveStates:
                logger.info("test sequence is not feasible")
            except:
                logger.info("test sequence timeout")
                pass 
            return status

        def greedyTesting(data, S, unauthorizedusers, desc):
            nonlocal safePrivilegeFlag,K
            # logger.info(desc)
            if len(S)>K:
                return
            if not symExec(unauthorizedusers, S):
                dfuncs = getDependentFuncs(S[-1])
                for dfunc in dfuncs:
                    S.append(dfunc)
                    attack_test_sequence = greedyTesting(data, S, unauthorizedusers, desc)
                    if attack_test_sequence is not None:
                        attack_test_sequences.append((data, attack_test_sequence))
                    S.pop()
            else:
                if desc.find("priviledgefuncs")!=-1:
                    # write2Exploit(f"Phase[{desc}], Bug[Permission Bug]: find a attack sequence {list(reversed(S))}")
                    logger.critical(f"Permission Bug: find an attack sequence {list(reversed(S))}")
                    write2Exploit(time.time()-start)
                    safePrivilegeFlag = False
                    unprotected_pfs.add(S[0])
                    attack_test_sequence = list(reversed(S))
                    return attack_test_sequence
            return None      
        if len(integrity_policies) == 0 and len(separation_policies) == 0:
            logger.warning("No permission policy is detected. No permission bug.")
            return 
        logger.info(f"Totally {len(integrity_policies)} integrity policies")
        logger.info(f"Totally {len(separation_policies)} integrity policies")
        
        # try:
        #     SymExecEVM().symCreateContractAccount(file=file, constructorargs = constructorargs, contract=contract, EthereumAddress=EthereumAddress)
        # except:
        #     logger.critical(f"{contract}-{EthereumAddress} cannot be deployed using manticore")
        #     return 

        for policy in integrity_policies:
            authorizedrole, unauthorizedrole, data, priviledgefuncs = policy
            unauthorizedusers = unauthorizedrole[0] - authorizedrole[0]
            priviledgefuncs = priviledgefuncs.difference(["constructor", "buy", "__fallback__", "fallback", "burn", "burnFrom", "fallback", "__callback", "transfer", "transferFrom", "approve", "setApprovalForAll", "approveAndCall", "safeTransferFrom", "increaseApproval", "decreaseApproval"])
            for pf in priviledgefuncs:
                Stack = list()
                Stack.append(pf)
                attack_test_sequence = greedyTesting(data, S=Stack, unauthorizedusers = unauthorizedusers, desc=f"Testing integrity priviledgefuncs...\nRh: {authorizedrole[1]}\nRl: {unauthorizedrole[1]}")
                if attack_test_sequence is not None:
                    attack_test_sequences.append((data, attack_test_sequence))

        for policy in separation_policies:
            authorizedrole, data, priviledgefuncs = policy
            unauthorizedusers = set(["0xC0ffee753b42bda1bcfa682f29685e2fd6729016"])
            priviledgefuncs = priviledgefuncs.difference( ["constructor",  "buy", "__fallback__", "fallback",  "burn",  "burnFrom", "fallback", "__callback", "transfer", "transferFrom", "approve", "setApprovalForAll", "approveAndCall", "safeTransferFrom", "increaseApproval", "decreaseApproval"])
            for pf in priviledgefuncs:
                Stack = list()
                Stack.append(pf)
                attack_test_sequence = greedyTesting(data, S=Stack, unauthorizedusers = unauthorizedusers, desc=f"Testing separation priviledgefuncs...\nR: {authorizedrole[1]}\n")
                if attack_test_sequence is not None:
                    attack_test_sequences.append((data, attack_test_sequence))

        timecost = time.time()-start
        logger.info(f"Testing time: {timecost} seconds")
        write2Exploit(timecost)