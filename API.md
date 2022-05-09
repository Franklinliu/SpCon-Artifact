   
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


    
   
### Function `ReduceMain` 




>     def ReduceMain(
>         roles
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






        
# Module `spcon.staticAnalyzer` 

## Functions


    
### Function `getRWofContract` 




>     def getRWofContract(
>         address
>     )




    


    
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




 
    
### Function `setContractAccount` 




>     def setContractAccount(
>         _targetrealworldaddress,
>         _contract_account
>     )




    
### Function `setDisable` 




>     def setDisable()




    
### Function `setEnable` 




>     def setEnable()



     
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


    
### Class `SymExecEVM` 

#### Methods

#### Method `symCreateContractAccount`


>     def symCreateContractAccount(
>         self,
>         contract,
>         EthereumAddress
>     )

#### Method `symExec`

>     def symExec(
>         self,
>         unauthorizedusers,
>         func,
>         func_mappings
>     )

#### Method `fuzzing`
>     @staticmethod
>     def fuzzing(
>         contract,
>         EthereumAddress,
>         separation_policies,
>         integrity_policies,
>         all_accessed_functions,
>         typesListofFuncs,
>         reads,
>         reads2,
>         writes
>     )