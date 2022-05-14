import argparse
import traceback
import time
from warnings import catch_warnings 
from .symExec import SymExecEVM
from .roleminer import runRoleMiningForSingleContract
from .query import main_collecttransaction_history
from .staticAnalyzer import getRWofContract
Mode_RoleMining = 1
Mode_Testing = 2

SYMENGINE_MANTICORE = "manticore"
SYMENGINE_MYTHRIL = "mythril"
def recoverLikelyRoleSecurityPolicy( address, contractName, contractAbi, generation, simratio, workdir, reads, reads2, writes,):
    # get contract reads writes for each function
    try:
        observed_methods, func_mappings, separation_policies, integrity_policies = runRoleMiningForSingleContract(address=address, \
            contractName=contractName, contractAbi= contractAbi, generation = generation, simratio=simratio, workdir=workdir, reads=reads, reads2=reads2, writes=writes) 
      
        return True, observed_methods, func_mappings, separation_policies, integrity_policies
    except:
        # traceback.print_exc()
        return False, None,  None,  None, None
       

def execute_command(args):
    contractName, contractAbi, reads, reads2, writes =  getRWofContract(address=args.eth_address)
    # print(contractName, contractAbi, reads, reads2, writes)
    main_collecttransaction_history(address=args.eth_address, workdir=args.workspace, date = args.date)

    boolflag, observed_methods, func_mappings, separation_policies, integrity_policies \
        = recoverLikelyRoleSecurityPolicy(address = args.eth_address, contractName = contractName, contractAbi = contractAbi,generation=args.generation, simratio=args.simratio, workdir=args.workspace, reads=reads, reads2=reads2, writes=writes)
    if args.mode == Mode_Testing:
        assert  boolflag==True, "Cannot infer security policies maybe because the number of historical transaction is small"
        try:
            SymExecEVM().fuzzing(contract=contractName, EthereumAddress=args.eth_address, separation_policies = separation_policies, integrity_policies=integrity_policies,\
                 all_accessed_functions=observed_methods, typesListofFuncs=func_mappings, reads=reads, reads2=reads2, writes=writes)
        except:
            # assert False, "Error in arguments --symEngine"
            traceback.print_exc()
            raise Exception("Unkown error")

def main():
    start = time.time()
    parser = argparse.ArgumentParser(description='SPCON, Mine role structures of smart contracts for permission bug detection!')
   
    parser.add_argument('--eth_address', type=str, required=True, 
                        help='Ethereum address of contract')

    parser.add_argument('--simratio', type=float, default = 0.50, 
                        help='ratio of simErr for GA. (default 0.50)')
    
    parser.add_argument('--generation', type=int, default = 100, 
                        help='the number of generations for GA. (default 100)')
    
    parser.add_argument('--mode', type=int, default = Mode_Testing , 
                        help='running mode either 1: Mode_RoleMining or 2: Mode_Testing (default Mode_Testing)' )
    
    parser.add_argument('--workspace', type=str, default = "./" , 
                        help='workspace directory (default ./)')

    parser.add_argument('--date', type=str, default = "latest" , 
                        help='use transaction history up to which date YYYY-MM-DD (default latest)')
    args = parser.parse_args()
    assert args is not None 
    try:
        execute_command(args)
    except:
        traceback.print_exc()
        pass 
    print(f"total timecost: {time.time() - start} seconds")

if __name__ ==  "__main__":
    main()