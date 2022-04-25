
# SPFuzzer smart contract permission fuzzer framework

import argparse
import functools
import logging
from os import read, write
import sys
import time
from numpy.lib.function_base import select

from mythril.laser.ethereum.svm import LaserEVM
from mythril.laser.plugin.interface import LaserPlugin
from mythril.laser.plugin.builder import PluginBuilder
from mythril.laser.ethereum.state.global_state import GlobalState
from mythril.laser.smt.bool import Or, And 

import mythril.interfaces.cli as mythrilcli

from manticore.ethereum.abi import ABI
import traceback
import functools

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


Policy_Type_Integrity = "integrity"
Policy_Type_Separation = "separation"


def Ors(trueval, args):
    if len(args)==0:
        return trueval
    return Ors(Or(trueval, args[0]), args[1:])

def Ands(trueval, args):
    if len(args)==0:
        return trueval
    return Ands(And(trueval, args[0]), args[1:])

LRU_CACHE_SIZE = 4096
Selectors = []

class ConstrainPluginBuilder(PluginBuilder):
    name = "Constrain provided by spcon"
    def __call__(self, *args, **kwargs):
        return ConstrainPlugin()

class ConstrainPlugin(LaserPlugin):
    def __init__(self) -> None:
        global Selectors
        self.selectors = Selectors
        logger.info("*****************************")
        logger.info("Hello world, this is spcon!!!\n")

    def initialize(self, symbolic_vm: LaserEVM):
    # def initialize(self, symbolic_vm):
        @symbolic_vm.laser_hook("execute_state")
        @functools.lru_cache(LRU_CACHE_SIZE)
        def execute_state_hook(global_state: GlobalState):
              txs = len(global_state.transaction_stack)
              if len(self.selectors) == 0:
                  return 
            #   print(f"txs: {txs}")
              if txs == 1:
                    # print("Ｇood start, Constrain states by Spcon!!!\n")
                    try:
                        transaction1 = global_state.transaction_stack[0][0]
                        call_data1 = transaction1.call_data 
                        constraint1 = Ors(False, [Ands(True, [call_data1[i] == int(selector[i]) for i in range(4)]) for selector in self.selectors])
                        global_state.world_state.constraints.append(constraint1)
                    except:
                        traceback.print_exc()
                        pass 
                    finally:
                        # logger.info("constrain the first transaction!")
                        pass 

def getFunctionSelectors(funcs, typesListofFuncs):
    selectors = set()

    for func in funcs:
        types = typesListofFuncs[func][0]
        sig = f"{func}({','.join(types)})"
        selectors.add(ABI.function_selector(sig))

    return selectors

def get_privandunusedfuncConstrainer(file, constructorargs, contract, EthereumAddress, policies, all_accessed_functions, typesListofFuncs, reads, writes):
    global Selectors
    if len(policies) == 0:
        return 
    logger.info(f"Totally {len(policies)} policies")
    start = time.time()

    all_priviledgefuncs = set()

    for policy in policies:
        authorizedrole, unauthorizedrole, priviledgefuncs, sortofpolicy = policy

        assert sortofpolicy in [Policy_Type_Integrity, Policy_Type_Separation]

        unauthorizedusers = unauthorizedrole[0][0] - authorizedrole[0][0] 

        all_priviledgefuncs.update(priviledgefuncs)

    all_priviledgefuncs.difference_update( ["constructor", "__fallback__", "fallback", "__callback", "transfer", "transferFrom", "approve", "setApprovalForAll", "safeTransferFrom", "increaseApproval", "decreaseApproval"])

    unused_functions = set(typesListofFuncs.keys()) - all_accessed_functions - priviledgefuncs

    considered_funcs = all_priviledgefuncs.union(unused_functions)
    selectors = getFunctionSelectors(considered_funcs, typesListofFuncs)
    print(f"considered selectors: {selectors} for functions {considered_funcs}")
    Selectors = selectors
    return selectors

def fuzzing(file, constructorargs, contract, EthereumAddress, policies, all_accessed_functions, typesListofFuncs, reads, writes):
    selectors = get_privandunusedfuncConstrainer(file, constructorargs, contract, EthereumAddress, policies, all_accessed_functions, typesListofFuncs, reads, writes)
    old_sys_argv = sys.argv 
    sys.argv = f'''myth -v 5 analyze -a {EthereumAddress} --infura-id 30df87c8ffa645cfaea52f6344791203 -m TxOrigin,ExternalCalls,IntegerArithmetics,ArbitraryDelegateCall,AccidentallyKillable,PredictableVariables,EtherThief --execution-timeout 1200'''.split(" ")
    print(sys.argv)
    try:
        mythrilcli.main()
    finally:
        sys.argv = old_sys_argv


