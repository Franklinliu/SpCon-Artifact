# SpCon: Finding Smart Contract Permission Bugs with Role Mining

This is the artifact associated with our ISSTA'22 paper.
We aim to apply for the availability, functionality and reusability badges.

This readme first shows how to quickly use SpCon to detect smart contract permission bugs. 
Secondly, we demostrate the technical detail namely SpCon API document for potential reusability or integration in the future.

## Requisite

Install a proper Docker software suitable for your operation system. 
Please refer to the official website https://docs.docker.com/get-docker/ how to install Docker.

## 1. Quick Start
[Recommened] Install && Run the SpCon docker image.

```bash 
# install docker image 
docker pull liuyedocker/spcon-artifact:latest 
# run spcon to detect the permisson bug of MorphToken(0x2Ef27BF41236bD859a95209e17a43Fbd26851f92) which is a CVE smart contract. 
docker run --rm liuyedocker/spcon-artifact:latest spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
``` 

After up to two minutes (default mode), we will see the results
```
Installing '0.4.18'...
Version '0.4.18' installed.
2022-05-01
{'limit': 10000, 'network': 'ethereum', 'address': '0x2Ef27BF41236bD859a95209e17a43Fbd26851f92', 'date': '2022-05-01'}
0x2Ef27BF41236bD859a95209e17a43Fbd26851f92 MorphToken
./0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
loaded abi.
https://www.4byte.directory/api/v1/signatures/?hex_signature=0x30783039
14  functions ['decimals', 'name', 'balanceOf', 'totalSupply', 'mintTokens', 'transferFrom', 'owned', 'transfer', 'burn', 'symbol', 'blacklistAccount', 'allowance', 'approve', 'transferOwnership']
2831  users
Timecost for loading history: 0.9801702499389648
No.user: 2831; No.func: 14
+-----------------------------------------------------+
|  Basic roles statistics (id, len(users), functions) |
+-----------+---------+-------------------------------+
|   RoleId  |  Users  |           Functions           |
+-----------+---------+-------------------------------+
|     0     |    2    |          ['decimals']         |
|     1     |    26   |         ['balanceOf']         |
|     2     |    23   |        ['transferFrom']       |
|     3     |    24   |           ['owned']           |
|     4     |   1830  |          ['transfer']         |
|     5     |    5    |         ['allowance']         |
|     6     |   1258  |          ['approve']          |
|     7     |    9    |         ['mintTokens']        |
|     8     |    3    |      ['blacklistAccount']     |
|     9     |    5    |     ['transferOwnership']     |
|     10    |    1    |       ['name', 'symbol']      |
|     11    |    1    |            ['burn']           |
|     12    |    1    |        ['totalSupply']        |
+-----------+---------+-------------------------------+
Gen. 0 (0.00%): Max/Min/Avg Fitness(Raw)             [1.94(2.05)/1.45(1.39)/1.62(1.62)]
Gen. 100 (100.00%): INFO:spcon.symExec:Totally 0 integrity policies
INFO:spcon.symExec:Totally 2 integrity policies
Max/Min/Avg Fitness(Raw)             [2.04(2.18)/1.49(1.40)/1.70(1.70)]
Total time elapsed: 19.663 seconds.
best role number: 6
Role#0:{'decimals', 'transferOwnership'}
Role#1:{'name', 'balanceOf', 'symbol'}
Role#2:{'transfer', 'transferFrom'}
Role#3:{'burn', 'owned', 'totalSupply', 'blacklistAccount'}
Role#4:{'allowance'}
Role#5:{'approve', 'mintTokens'}
Time cost: 21.463589668273926
Security Policy:
Policy#0: approve mintTokens -> allowed via functions approve
Policy#1: burn owned totalSupply blacklistAccount -> owner isblacklistedAccount via functions owned blacklistAccount
2022-05-01 16:59:50,416: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xce\xff\xeeu;B\xbd\xa1\xbc\xfah/)h^/\xd6r\x90\x16\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01' -> 31685667446001209947968549300437926627890736099156269050595801945717492225074
2022-05-01 16:59:51,879: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04' -> 62514009886607029107290561805838585334079798074568712924583230797734656856475
2022-05-01 16:59:54,797: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05' -> 1546678032441257452667456735582814959992782782816731922691272282333561699760
INFO:spcon.symExec:Test Sequence: ['owned']
INFO:spcon.symExec:SymExecEVM().symExec: owned()
INFO:spcon.symExec:attacker: 0xc0ffee753b42bda1bcfa682f29685e2fd6729016
INFO:spcon.symExec:transaction status: success
CRITICAL:spcon.symExec:Permission Bug: find an attack sequence ['owned']
https://api.etherscan.io/api?module=proxy&action=eth_getStorageAt&address=0x2Ef27BF41236bD859a95209e17a43Fbd26851f92&position=0x0&tag=latest&apikey=URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ
https://api.etherscan.io/api?module=proxy&action=eth_getStorageAt&address=0x2Ef27BF41236bD859a95209e17a43Fbd26851f92&position=0x0&tag=latest&apikey=URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ
2022-05-01 17:00:02,940: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xce\xff\xeeu;B\xbd\xa1\xbc\xfah/)h^/\xd6r\x90\x16\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01' -> 31685667446001209947968549300437926627890736099156269050595801945717492225074
2022-05-01 17:00:04,392: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04' -> 62514009886607029107290561805838585334079798074568712924583230797734656856475
2022-05-01 17:00:07,381: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05' -> 1546678032441257452667456735582814959992782782816731922691272282333561699760
INFO:spcon.symExec:Test Sequence: ['blacklistAccount']
INFO:spcon.symExec:SymExecEVM().symExec: blacklistAccount(address,bool)
INFO:spcon.symExec:attacker: 0xc0ffee753b42bda1bcfa682f29685e2fd6729016
INFO:spcon.symExec:transaction status: false
INFO:spcon.symExec:test sequence is not feasible
2022-05-01 17:00:16,755: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xce\xff\xeeu;B\xbd\xa1\xbc\xfah/)h^/\xd6r\x90\x16\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01' -> 31685667446001209947968549300437926627890736099156269050595801945717492225074
2022-05-01 17:00:18,306: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04' -> 62514009886607029107290561805838585334079798074568712924583230797734656856475
2022-05-01 17:00:21,647: [1] m.e.manticore:INFO: Found a concrete globalsha3 b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05' -> 1546678032441257452667456735582814959992782782816731922691272282333561699760
INFO:spcon.symExec:Test Sequence: ['owned', 'blacklistAccount']
INFO:spcon.symExec:SymExecEVM().symExec: owned()
INFO:spcon.symExec:attacker: 0xc0ffee753b42bda1bcfa682f29685e2fd6729016
INFO:spcon.symExec:transaction status: success
INFO:spcon.symExec:SymExecEVM().symExec: blacklistAccount(address,bool)
INFO:spcon.symExec:attacker: 0xc0ffee753b42bda1bcfa682f29685e2fd6729016
INFO:spcon.symExec:transaction status: success
CRITICAL:spcon.symExec:Permission Bug: find an attack sequence ['owned', 'blacklistAccount']
INFO:spcon.symExec:Testing time: 43.04372596740723 seconds
total timecost: 70.84923839569092 seconds
```

The result shows permission attack sequences ``['owned']``, ``['owned', 'blacklistAccount']``  that can exploit the permission bug of the smart contract.


## 2. Build from scratch
- Dockerization of this artifact  
   ```bash
   # execute the below instructions and
    docker build . -t spcon-artifact
   #  the local spcon-artifact will be made (about 10minutes at the first making)
   # please verify if the docker can work as well by running the docker image for permission bug detection.
   docker run --rm spcon-artifact:latest spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
   ```
- Running this artifact on the local machine. (This way works well on Ubuntu 20.04 and Python 3.8.2.)
   ```bash 
   # install all the dependencies of the artifact
   bash ./localbuild.sh
   # this would depend on your opertation environment and may not spent more than 10 minutes
   # please verify if the following instruction can work as well for finding permissiong bugs of smart contract.
   spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
   ```

## 3. Experiement evaluation
- Repository Structure 
```
spcon-artifact
│   README.md
│   localBuild.sh   
│   Dockerfile
|   CVE.list  this file contains the address of access control CVE smart contracts
|
└───ISSTA2022
│   │   
│   └─── CVEAccessControlResults  this folder contains the access control CVE smart contracts and the CVE smart contracts that only spcon can detect. 
│   │
│   └─── RoleMiningBenchmarkandResults   this folder contains benchmark and raw experiment result.
|   │
|   └─── SmartBugsWildResults  this foler contains the detection result on benchmark SmartBugs and its comparison with existing state-of-the-arts.
|
|   setup.py
└───spcon
    │   __main__.py  the entry script for spcon
    │   query.py
    |   roleminger.py
    |   staticAnalyzer.py
    |   symExec.py
    └───spconbenchmarkminer.py  used for role mining evaluation on the benchmarks
```
- Role Mining Evaluation.
  
  The following instruction would help evaluate the result of role mining on the OpenZeppelin benchmark smart contracts. 
  
```bash 
  # from pulled docker image
  docker run --rm liuyedocker/spcon-artifact benchmarkminer --limit 2
  # currently it will evaluate on 2 benchmark contracts. This would take about three minutes.
  # Moreover, if we would like to export the output result to your local machine. Please using docker volumn mount instruction as the following.
  docker run --rm -v $HOME/localtmp:/dockertmp liuyedocker/spcon-artifact benchmarkminer --limit 2 --output /dockertmp/result.xlsx
  # Once done, you can check the exported result file at the path $HOME/localtmp/result.xlsx
```

- Permission Bug Detection
  
SpCon detected the bugs of nine contracts out of 17 access control CVE smart contracts.
For time saving, you can evaluate it using the following bash script.
```bash 
 while read -r line; do docker run --rm liuyedocker/spcon-artifact spcon --eth_address $line; done < CVE.list
 # this would take half an hour to execute all cases. 
```
  
## 4. Code API Document

