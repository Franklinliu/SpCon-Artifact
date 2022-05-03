---
description: |
    API documentation for modules: spcon, spcon.query, spcon.roleminer, spcon.spconbenchmarkminer, spcon.staticAnalyzer, spcon.symExec.

lang: en

classoption: oneside
geometry: margin=1in
papersize: a4

linkcolor: blue
links-as-notes: true
...


    
# Module `spcon` {#id}




    
## Sub-modules

* [spcon.query](#spcon.query)
* [spcon.roleminer](#spcon.roleminer)
* [spcon.spconbenchmarkminer](#spcon.spconbenchmarkminer)
* [spcon.staticAnalyzer](#spcon.staticAnalyzer)
* [spcon.symExec](#spcon.symExec)






    
# Module `spcon.query` {#id}






    
## Functions


    
### Function `main_collecttransaction_history` {#id}




>     def main_collecttransaction_history(
>         address,
>         workdir='./',
>         date='latest'
>     )




    
### Function `run_query` {#id}




>     def run_query(
>         query,
>         variables
>     )







    
# Module `spcon.roleminer` {#id}






    
## Functions


    
### Function `DeriveRolePermissionPolicy` {#id}




>     def DeriveRolePermissionPolicy(
>         reads,
>         reads2,
>         writes
>     )




    
### Function `ReduceMain` {#id}




>     def ReduceMain(
>         roles
>     )




    
### Function `buildRoleHierarchy` {#id}




>     def buildRoleHierarchy(
>         roles
>     )




    
### Function `dfsReduceRecursive` {#id}




>     def dfsReduceRecursive(
>         roles,
>         i
>     )




    
### Function `getABI_file` {#id}




>     def getABI_file(
>         directory
>     )




    
### Function `getABIfunction_signature_mapping` {#id}




>     def getABIfunction_signature_mapping(
>         abi
>     )




    
### Function `getABIfunctions` {#id}




>     def getABIfunctions(
>         abi_file
>     )




    
### Function `getMethodName` {#id}




>     def getMethodName(
>         hex_signature
>     )




    
### Function `lightweightrolemining` {#id}




>     def lightweightrolemining(
>         address,
>         abi,
>         gene_encoding,
>         generation,
>         simratio,
>         workdir
>     )




    
### Function `runRoleMiningForSingleContract` {#id}




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


    
### Class `GA_RM` {#id}




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


    
##### Method `calcsimilarity` {#id}




>     def calcsimilarity(
>         self,
>         roleA,
>         roleB
>     )




    
##### Method `createBasicLatticeRoles` {#id}




>     def createBasicLatticeRoles(
>         self,
>         users
>     )




    
##### Method `getAFV` {#id}




>     def getAFV(
>         self,
>         role
>     )




    
##### Method `getTestingBasicRoles` {#id}




>     def getTestingBasicRoles(
>         self
>     )




    
##### Method `getTrainingBasicRoles` {#id}




>     def getTrainingBasicRoles(
>         self
>     )




    
##### Method `getUserFunctionCount` {#id}




>     def getUserFunctionCount(
>         self,
>         user,
>         method
>     )




    
##### Method `miningWithGAWith1DRealChromosome` {#id}




>     def miningWithGAWith1DRealChromosome(
>         self
>     )




    
##### Method `process` {#id}




>     def process(
>         self
>     )




    
##### Method `translateLattice2Role` {#id}




>     def translateLattice2Role(
>         self,
>         lattice
>     )






    
# Module `spcon.spconbenchmarkminer` {#id}






    
## Functions


    
### Function `ReduceMain` {#id}




>     def ReduceMain(
>         roles
>     )




    
### Function `appendExcelRow` {#id}




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




    
### Function `buildRoleHierarchy` {#id}




>     def buildRoleHierarchy(
>         roles
>     )




    
### Function `compareRoleSets` {#id}




>     def compareRoleSets(
>         mined_roles,
>         deployed_roles,
>         t=1.0
>     )




    
### Function `dfsReduceRecursive` {#id}




>     def dfsReduceRecursive(
>         roles,
>         i
>     )




    
### Function `getABI_file` {#id}




>     def getABI_file(
>         directory
>     )




    
### Function `getABIfunction_signature_mapping` {#id}




>     def getABIfunction_signature_mapping(
>         abi_file
>     )




    
### Function `getABIfunctions` {#id}




>     def getABIfunctions(
>         abi_file
>     )




    
### Function `getMethodName` {#id}




>     def getMethodName(
>         hex_signature
>     )




    
### Function `getSetOfSimilarityMetrics` {#id}




>     def getSetOfSimilarityMetrics(
>         mined_roles,
>         deployed_roles
>     )




    
### Function `initExcelHead` {#id}




>     def initExcelHead(
>         ws_result
>     )




    
### Function `jaccard_func` {#id}




>     def jaccard_func(
>         set1,
>         set2
>     )




    
### Function `label_func` {#id}




>     def label_func(
>         role_permission_functions,
>         other_permission_functions,
>         ABIfunctions
>     )




    
### Function `lightweightrolemining` {#id}




>     def lightweightrolemining(
>         address,
>         gene_encoding,
>         simratio,
>         workdir
>     )




    
### Function `main` {#id}




>     def main()




    
### Function `roleset_roleset_jaccard_func_old_donot_purse_one2one` {#id}




>     def roleset_roleset_jaccard_func_old_donot_purse_one2one(
>         roleset1,
>         roleset2,
>         t=1
>     )





    
## Classes


    
### Class `GA_RM` {#id}




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


    
##### Method `calcsimilarity` {#id}




>     def calcsimilarity(
>         self,
>         roleA,
>         roleB
>     )




    
##### Method `createBasicLatticeRoles` {#id}




>     def createBasicLatticeRoles(
>         self,
>         users
>     )




    
##### Method `getAFV` {#id}




>     def getAFV(
>         self,
>         role
>     )




    
##### Method `getTestingBasicRoles` {#id}




>     def getTestingBasicRoles(
>         self
>     )




    
##### Method `getTrainingBasicRoles` {#id}




>     def getTrainingBasicRoles(
>         self
>     )




    
##### Method `getUserFunctionCount` {#id}




>     def getUserFunctionCount(
>         self,
>         user,
>         method
>     )




    
##### Method `miningWithGAWith1DRealChromosome` {#id}




>     def miningWithGAWith1DRealChromosome(
>         self
>     )




    
##### Method `process` {#id}




>     def process(
>         self
>     )




    
##### Method `translateLattice2Role` {#id}




>     def translateLattice2Role(
>         self,
>         lattice
>     )






    
# Module `spcon.staticAnalyzer` {#id}






    
## Functions


    
### Function `getRWofContract` {#id}




>     def getRWofContract(
>         address
>     )




    
### Function `test` {#id}




>     def test()





    
## Classes


    
### Class `Analyzer` {#id}




>     class Analyzer










    
#### Methods


    
##### Method `analyze` {#id}




>     def analyze(
>         self,
>         address
>     )




    
##### Method `controldependency` {#id}




>     def controldependency(
>         self,
>         function
>     )






    
# Module `spcon.symExec` {#id}






    
## Functions


    
### Function `BlockchainInfo` {#id}




>     def BlockchainInfo(
>         *args,
>         **kwargs
>     )




    
### Function `SymExecEVM` {#id}




>     def SymExecEVM(
>         *args,
>         **kwargs
>     )




    
### Function `ethGetCode` {#id}




>     def ethGetCode(
>         state,
>         address
>     )




    
### Function `ethGetStorageAt` {#id}




>     def ethGetStorageAt(
>         state,
>         storage_address,
>         offset
>     )




    
### Function `eth_GetBalanceOf` {#id}




>     def eth_GetBalanceOf()




    
### Function `eth_GetCode` {#id}




>     def eth_GetCode()




    
### Function `getAPIData` {#id}




>     def getAPIData(
>         url
>     )




    
### Function `getPage` {#id}




>     def getPage(
>         url
>     )




    
### Function `getPage0` {#id}




>     def getPage0(
>         url
>     )




    
### Function `getPage1` {#id}




>     def getPage1(
>         url
>     )




    
### Function `getPage2` {#id}




>     def getPage2(
>         url
>     )




    
### Function `setContractAccount` {#id}




>     def setContractAccount(
>         _targetrealworldaddress,
>         _contract_account
>     )




    
### Function `setDisable` {#id}




>     def setDisable()




    
### Function `setEnable` {#id}




>     def setEnable()




    
### Function `singleton` {#id}




>     def singleton(
>         class_
>     )




    
### Function `wraper` {#id}




>     def wraper(
>         state,
>         storage_address,
>         offset
>     )





    
## Classes


    
### Class `CodeMonitor` {#id}




>     class CodeMonitor


This just aborts explorations that are too deep


    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_evm_read_code_callback` {#id}




>     def did_evm_read_code_callback(
>         self,
>         state,
>         address,
>         offset,
>         size,
>         *args
>     )




    
##### Method `will_evm_read_code_callback` {#id}




>     def will_evm_read_code_callback(
>         self,
>         state,
>         address,
>         *args
>     )




    
### Class `ForkMonitor` {#id}




>     class ForkMonitor





    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_fork_state_callback` {#id}




>     def did_fork_state_callback(
>         self,
>         state,
>         expression,
>         solutions,
>         policy,
>         children
>     )




    
### Class `StorageRWMonitor` {#id}




>     class StorageRWMonitor


This just aborts explorations that are too deep


    
#### Ancestors (in MRO)

* [manticore.core.plugin.Plugin](#manticore.core.plugin.Plugin)






    
#### Methods


    
##### Method `did_evm_read_storage_callback` {#id}




>     def did_evm_read_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         *args
>     )




    
##### Method `will_evm_read_storage_callback` {#id}




>     def will_evm_read_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         *args
>     )




    
##### Method `will_evm_write_storage_callback` {#id}




>     def will_evm_write_storage_callback(
>         self,
>         state,
>         storage_address,
>         offset,
>         value,
>         *args
>     )





-----
Generated by *pdoc* 0.10.0 (<https://pdoc3.github.io>)./usr/local/lib/python3.8/dist-packages/pdoc/cli.py:534: UserWarning: Couldn't read PEP-224 variable docstrings from <Module 'spcon'>: could not get source code
  modules = [pdoc.Module(module, docfilter=docfilter,
/usr/local/lib/python3.8/dist-packages/eth_utils-1.10.0-py3.8.egg/eth_utils/toolz.py:2: DeprecationWarning: The toolz.compatibility module is no longer needed in Python 3 and has been deprecated. Please import these utilities directly from the standard library. This module will be removed in a future release.
  from cytoolz import (

PDF-ready markdown written to standard output.
                              ^^^^^^^^^^^^^^^
Convert this file to PDF using e.g. Pandoc:

    pandoc --metadata=title:"MyProject Documentation"               \
           --from=markdown+abbreviations+tex_math_single_backslash  \
           --pdf-engine=xelatex --variable=mainfont:"DejaVu Sans"   \
           --toc --toc-depth=4 --output=pdf.pdf  pdf.md

or using Python-Markdown and Chrome/Chromium/WkHtmlToPDF:

    markdown_py --extension=meta         \
                --extension=abbr         \
                --extension=attr_list    \
                --extension=def_list     \
                --extension=fenced_code  \
                --extension=footnotes    \
                --extension=tables       \
                --extension=admonition   \
                --extension=smarty       \
                --extension=toc          \
                pdf.md > pdf.html

    chromium --headless --disable-gpu --print-to-pdf=pdf.pdf pdf.html

    wkhtmltopdf --encoding utf8 -s A4 --print-media-type pdf.html pdf.pdf

or similar, at your own discretion.

