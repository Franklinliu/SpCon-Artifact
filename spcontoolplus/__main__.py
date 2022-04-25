import argparse
import json
import traceback
from .crawler.crawler import Crawler
from .crawler.crawler import BLOCKCHAIN_ETH
from .driver.symExec import SymExecEVM
import os 
from .driver.minerForOpenZeppelin_version8_securitylattice import runRoleMiningForSingleContract
Mode_RoleMining = 1
Mode_Testing = 2

SYMENGINE_MANTICORE = "manticore"
SYMENGINE_MYTHRIL = "mythril"
def filterandInstallSolcCompilerversion(compiler_version):
    if compiler_version.find("commit")!=-1:
        compiler_version = compiler_version.split("+commit")[0].split("v")[1]
    if compiler_version.find("night")!=-1:
        compiler_version = compiler_version.split("-night")[0]
        if compiler_version.find("v")!=-1:
            compiler_version = compiler_version.split("v")[1]
        
    if compiler_version:
        # TODO
        import subprocess
        
        exitcode = subprocess.run(["solc-select","use", compiler_version])
        print(exitcode.returncode)
        if int(exitcode.returncode) != 0:
            print(f"version not exists, install {compiler_version}")
            exitcode = subprocess.run(["solc-select","install", compiler_version])
            exitcode = subprocess.run(["solc-select","use", compiler_version])

    return compiler_version

def recoverLikelyRoleSecurityPolicy(name, address, simratio, workdir):
    # get contract reads writes for each function
    try:
        observed_methods, func_mappings, reads, reads2, writes, separation_policies, integrity_policies = runRoleMiningForSingleContract(address=address, contractName=name, simratio=simratio, workdir=workdir) 
      
        return True, observed_methods, func_mappings, reads, reads2, writes, separation_policies, integrity_policies
    except:
        traceback.print_exc()
        return False, None,  None, None, None, None, None, None
       

def execute_command(args):
    # print(args)
    Workdir = os.path.abspath("./")
    crawler = Crawler(address = args.contract_address, blockchain=args.blockchain, workdir=args.workspace, date=args.date)
    results = crawler.crawl()
    print(results)
    from spcontoolplus.txparser.decoder import ContractAbi 
    abi = ContractAbi(json.load(open(results["abi_file"])))
    parameter =  abi.decode_constructor(bytes.fromhex(results["arguments"])).inputs 
    results["arguments"] = tuple(map(lambda input: int(input["data"],16) if input["type"]=="address" else input["data"],parameter))
    print("constructor arguments: ",  results["arguments"])

    filterandInstallSolcCompilerversion(results["compiler_version"])

    boolflag, observed_methods, func_mappings, reads, reads2, writes, separation_policies, integrity_policies = recoverLikelyRoleSecurityPolicy(name=results["name"], address = results["address"], simratio=args.simratio, workdir=args.workspace)
    if args.mode == Mode_Testing:
        assert  boolflag==True, "security policies inference error"
        if args.symEngine == SYMENGINE_MANTICORE:
            # print("testing")
            SymExecEVM().fuzzing(file=os.path.join(Workdir, results["sourcecode_file"]), constructorargs=results["arguments"], contract=results["name"], EthereumAddress= results["address"], separation_policies = separation_policies, integrity_policies=integrity_policies, all_accessed_functions=observed_methods, typesListofFuncs=func_mappings, reads=reads, reads2=reads2, writes=writes)
        elif args.symEngine == SYMENGINE_MYTHRIL:
            from .driver import mythrilplugin as mythplugin
            mythplugin.fuzzing(file=os.path.join(Workdir, results["sourcecode_file"]), constructorargs=results["arguments"], contract=results["name"], EthereumAddress= results["address"], separation_policies = separation_policies, integrity_policies=integrity_policies, all_accessed_functions=observed_methods, typesListofFuncs=func_mappings, reads=reads, writes=writes)
        else:
            assert False, "Error in arguments --symEngine"

def main():
    import sys
    import time 
    start = time.time()
    parser = argparse.ArgumentParser(description='SPCON, Mine role structures of smart contracts for permission bug detection!')
   
    parser.add_argument('--contract_address', type=str, required=True, 
                        help='contract address of contract')
    
    parser.add_argument('--blockchain', type=str, default = BLOCKCHAIN_ETH, 
                        help='blockchain (currently support ETH and BSC)')  

    parser.add_argument('--symEngine', type=str, default = SYMENGINE_MANTICORE, 
                        help='symbolic engine (currently support Manticore and Mythril)')                  
    
    parser.add_argument('--simratio', type=float, default = 0.40, 
                        help='ratio of simErr for GA. (default 0.40)')
    
    parser.add_argument('--gene_encoding', type=str, default = "real", 
                        help='gene encoding either "binary" or "real"')
    
    parser.add_argument('--mode', type=int, default = Mode_RoleMining , 
                        help='running mode either 1: Mode_RoleMining or 2: Mode_Testing')
    
    parser.add_argument('--workspace', type=str, default = "./" , 
                        help='workspace directory (default ./)')

    parser.add_argument('--date', type=str, default = "latest" , 
                        help='use transaction history up to which date YYYY-MM-DD (default latest)')
    args = parser.parse_args()
    try:
        execute_command(args)
    except:
        # traceback.print_exc()d
        print(f"total timecost: {time.time() - start}")

if __name__ ==  "__main__":
    main()