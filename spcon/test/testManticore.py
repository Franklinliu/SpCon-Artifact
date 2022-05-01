from manticore.ethereum import  ManticoreEVM
def test():
    export_dir = "crytic-export"
    etherscan_export_dir="etherscan-contracts2"
    etherscan_api_key = "URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ"
    network = "mainet"
    address = "0x33c2DA7Fd5B125E629B3950f3c38d7f721D7B30D"
    contractName = "Seal"
    m = ManticoreEVM()
    compile_args = dict(target=address, export_dir = export_dir, \
                     etherscan_export_dir = etherscan_export_dir, compile_remove_metadata=False, \
                etherscan_api_key = etherscan_api_key)
    print(compile_args)
    owner_account = m.create_account(balance=100000000000000, address= int("0xCeffee753b42bda1bcfa682f29685e2fd6729016", 16))
    contractAccount = m.solidity_create_contract(source_code = address, \
        owner = owner_account, name = contractName, contract_name = contractName, libraries = None, \
             balance= 0, address= None, args = None, gas = None, \
                 compile_args = dict(export_dir = export_dir, \
                     etherscan_export_dir = etherscan_export_dir, compile_remove_metadata=False, \
                etherscan_api_key = etherscan_api_key))
    print(contractAccount)

if __name__ == "__main__":
    test()