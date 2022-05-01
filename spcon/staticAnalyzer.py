

from pathlib import PosixPath
import posixpath
from slither.core.declarations.solidity_variables import SolidityFunction
from slither.slither import Slither  
from pprint import pprint
from prettytable import PrettyTable
from slither.core.declarations.function import Function
from slither.printers.summary.data_depenency import _get 
from slither.core.declarations.function import Function
from slither.analyses.data_dependency.data_dependency import compute_dependency
from slither.analyses.data_dependency.data_dependency import pprint_dependency
from slither.analyses.data_dependency.data_dependency import is_dependent
from crytic_compile import CryticCompile
import os 
import itertools
KEY_NON_SSA = "DATA_DEPENDENCY"

def getRWofContract(address):
    analyzer = Analyzer()
    contractName, contractAbi, reads, reads2,  writes = analyzer.analyze(address=address)
    return contractName, contractAbi, reads, reads2, writes

class Analyzer:
    def analyze(self, address):
        assert address is not None
        export_dir = "crytic-export"
        etherscan_export_dir="etherscan-contracts2"
        etherscan_api_key = "URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ"
        network = "mainet"
        contract = None
        funs = dict() 
        funs_mutable_public = dict()
        reads, writes =  dict(), dict()
        reads2 = dict()
        cc = CryticCompile(target=f"{network}:{address}", export_dir = export_dir, etherscan_export_dir = etherscan_export_dir, compile_remove_metadata=False, \
                etherscan_api_key = etherscan_api_key)
        slither = Slither(cc)
        working_dir: PosixPath = cc.working_dir 
        contract_dir = os.path.join(working_dir.absolute(),export_dir, etherscan_export_dir)
        # print(working_dir.absolute())
        contractName = None 
        for item in os.listdir(contract_dir):
            if item.startswith(address):
                contractName = item.split("-")[1]
                if contractName.find(".sol")!=-1:
                    contractName = contractName.split(".sol")[0]
                    break 
        assert contractName is not None 
        compilation_unit = cc.compilation_units[contractName]
        contractAbi = compilation_unit.abi(contractName)
        compute_dependency(compilation_unit=slither)
        contract = slither.get_contract_from_name(contractName)[0]
        # print(contract)
        # [ print(item) for item in contract]
        for function in contract.functions:
            if (function.visibility == "public" or function.visibility == "external") and function.view == False if hasattr(function,"view") else function.pure == False if hasattr(function, "pure") else True:
                if function.is_constructor:
                    function.name = "constructor"
                funs_mutable_public[function.name] = function
                all_state_variables_read_on_conditional_nodes, state_variables_written,  state_variables_read = \
                self.controldependency(function)
                reads2[function.name] = state_variables_read
                if len(all_state_variables_read_on_conditional_nodes)>0:
                    reads[function.name] = all_state_variables_read_on_conditional_nodes
                else:
                    reads[function.name] = set()
                if len(state_variables_written)>0:
                    writes[function.name] = state_variables_written
                else:
                    writes[function.name] = set()
            funs[function.name] = function
           
        # print("Write:", writes)
        # print("Read:", reads)
        return contractName, contractAbi, reads, reads2, writes
   
    def controldependency(self, function):
        all_functions =  function.modifiers +  [function]
        all_nodesSet = [f.nodes for f in all_functions if isinstance(f, Function)]
        all_nodes = [item for sublist in all_nodesSet for item in sublist]

        all_conditional_nodes = [
            n for n in all_nodes if n.contains_if() or n.contains_require_or_assert() or n.can_send_eth()
        ]
        conditional_use_function_calls = itertools.chain.from_iterable([ n.internal_calls for n in all_conditional_nodes])
        
        all_state_variables_read_on_conditional_nodes = set()
        for n in all_conditional_nodes:
            all_state_variables_read_on_conditional_nodes.update([v.name for v in n.state_variables_read])
     
        # state_variables_written = set([v.name for v in function.all_state_variables_written() ])
        # state_variables_read = set([v.name for v in function.all_state_variables_read()])

        state_variables_written = set() 
        state_variables_read = set() 
        for n in all_nodes:
            state_variables_read = state_variables_read.union([v.name for v in n.state_variables_read])
            state_variables_written = state_variables_written.union(set([v.name for v in n.state_variables_written]).difference(state_variables_read))
        state_variables_read = state_variables_read.difference(state_variables_written)
        
        for func in all_functions:
            all_internal_calls =  func.all_internal_calls()
            for f in all_internal_calls:
                if isinstance(f, Function):
                    _all_state_variables_read_on_conditional_nodes, _state_variables_written, _state_variables_read \
                        = self.controldependency(f)
                    all_state_variables_read_on_conditional_nodes.update(_all_state_variables_read_on_conditional_nodes)    
                    state_variables_written.update(_state_variables_written)
                    state_variables_read.update(_state_variables_read)

        for f in conditional_use_function_calls:
            if isinstance(f, Function):
                    _all_state_variables_read_on_conditional_nodes, _state_variables_written, _state_variables_read \
                        = self.controldependency(f)
                    all_state_variables_read_on_conditional_nodes.update(_all_state_variables_read_on_conditional_nodes)
                    all_state_variables_read_on_conditional_nodes.update(_state_variables_read)       
                    state_variables_written.update(_state_variables_written)
                    state_variables_read.update(_state_variables_read)
        
        return all_state_variables_read_on_conditional_nodes, state_variables_written, state_variables_read
    
def test():
    address = "0x0b509f4b044f713a91bb50535914f7ad160532fe"
    analyzer = Analyzer()
    contractName, contractAbi, reads, reads2, writes = analyzer.analyze(address = address)
    print(contractName)
    print(contractAbi)
    print(reads, reads2, writes)

if __name__ == "__main__":
    test()