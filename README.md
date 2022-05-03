# SpCon: Finding Smart Contract Permission Bugs with Role Mining

This is the artifact associated with our ISSTA'22 paper.
We aim to apply for the availability, functionality and reusability badges.

This readme first shows how to quickly use SpCon to detect smart contract permission bugs. 
Secondly, we demostrate the technical detail namely SpCon API document for potential reusability or integration in the future.


## Root Directory Structure 
```
spcon-artifact
│   README.md
│   localBuild.sh   
│   Dockerfile
|   CVE.list  
|
└───ISSTA2022
│   │   
│   └─── CVEAccessControlResults  
│   │
│   └─── RoleMiningBenchmarkandResults   
|   │
|   └─── SmartBugsWildResults 
|
|   setup.py
└───spcon
    │   __main__.py  
    │   query.py
    |   roleminger.py
    |   staticAnalyzer.py
    |   symExec.py
    └── spconbenchmarkminer.py  
```
There are serveral folders and files inside the repository, for replicating the experiments listed in the paper and supporting the standalone resuable components.

| File/Dir                      |  Description                                                                      |
|-------------------------------|-----------------------------------------------------------------------------------|
| REAME.md                      | refers to this readme.                                                            |
| localBuild.sh                 | used for local installation. See [here](#local-build)                      |
| Dockerfile                    | docker image make file, used for dockerization. See [here](#dockerization)   |             
| CVE.list                      | contains the address of access control CVE smart contracts. See [here](#experiement-evaluation)                        |
| CVEAccessControlResults       | contains the 17 access control CVE smart contracts and the detection result       |
| RoleMiningBenchmarkandResults | contains benchmark and raw experiment result.                                     |
| SmartBugsWildResults          | contains the detection result on benchmark SmartBugs.                             |
| spcon                         | the tool used for smart contract role mining and permission bug detection.        |
|                               |                                                                                   |


## Quick Start

### Prerequisite
We assume the users have installed Docker software suitable for their operation system. 
If not, please refer to the official website https://docs.docker.com/get-docker/ how to install Docker.

The quick start can use the public docker image prepared for this artifact evalution.
The two basic operation is to pull the docker image (from dockerhub) and then run a docker container to execute a task.
Below shows the proper instructions for this.  
```bash 
# install docker image 
docker pull liuyedocker/spcon-artifact:latest 
# run spcon to detect the permisson bug of MorphToken(0x2Ef27BF41236bD859a95209e17a43Fbd26851f92) which is a CVE smart contract. 
docker run --rm liuyedocker/spcon-artifact:latest spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
``` 
The above task to execute will take no more than two minutes if everything is going well. 
We will get the expected results in the terminal.
The terminal output will demostrate the information such as compiler versions, function name list, total users, uers-functions analysis and the mined best roles and its time cost by the GA role mining algorithm, 
then followed by a set of security policies as well as the conclic test process to find a set of attack sequence to break the security policies.  
The result shows permission attack sequences ``['owned']``, ``['owned', 'blacklistAccount']``  that can exploit the permission bug of the smart contract.

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

## Build from scratch
We provide two ways to build spcon from scratch.

### Dockerization 
The first one is to compile local docker image of SpCon using the provided Dockerfile.
The local spcon-artifact will be made about 10minutes at the first time.
Due to the layer mechanism of Docker, it would spend about two minutes if you later recompile the docker image for any update to the spcon implementation.
```bash
# execute the below instructions and
docker build . -t spcon-artifact
# please verify if the docker can work as well by running the docker image for permission bug detection.
docker run --rm spcon-artifact:latest spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
```
### Local Build
Prerequisite
+ Python3.8
+ Ubuntu xxx (This works well on Ubuntu 20.04)
  
Local build is supported for this artifact project.
We provide a script `localBuild.sh` to help you install all the dependencies and install SpCon in your system `$PATH` directory.
Please run the below instructions to install SpCon and then run SpCon for permission bug detection. 
   ```bash 
   # install all the dependencies of the artifact
   bash ./localbuild.sh
   # this would depend on your opertation environment and may not spent more than 10 minutes
   # please verify if the following instruction can work as well for finding permissiong bugs of smart contract.
   spcon --eth_contract 0x2Ef27BF41236bD859a95209e17a43Fbd26851f92
   ```

## Experiement evaluation

We present sufficient information to evaluate the role mining and the permission bug detection.

### Role Mining Evaluation.

We make a tool `benchmarkminer` to evaluate role mining on any benchmark smart contracts with groundtruth.
By default, `benchmarkminer` will evaluate on the provided OpenZeppelin benchmark samrt contracts (`./ISSTA2022/RoleMiningBenchmarkandResults/OpenZeppelin1000
calls10methods`) with the manually verified ground truth (`./ISSTA2022/RoleMiningBench
markandResults/OpenZeppelin1000calls10methods-label.xlsx`).
```
usage: benchmarkminer [-h] [--benchmark BENCHMARK] [--groundtruth GROUNDTRUTH]
                      [--output OUTPUT] [--simratio SIMRATIO] [--limit LIMIT]

SPCONMiner, Mining smart contract role structures

optional arguments:
  -h, --help            show this help message and exit
  --benchmark BENCHMARK
                        benchmark directory (default ./ISSTA2022/RoleMiningBen
                        chmarkandResults/OpenZeppelin1000calls10methods)
  --groundtruth GROUNDTRUTH
                        the labelled role structure (ground truth) for the
                        benchmark (default ./ISSTA2022/RoleMiningBenchmarkandR
                        esults/OpenZeppelin1000calls10methods-label.xlsx)
  --output OUTPUT       the output file containing result of mined role
                        structure and its comparison with the ground truth
                        (./result-OpenZeppelin_spconminer.xlsx)
  --simratio SIMRATIO   ratio of simErr for GA. (default 0.40)
  --limit LIMIT         how many benchmark contracts are inspected for the
                        role mining. (default 50)
```
The following instruction would evaluate the result of role mining on two OpenZeppelin benchmark smart contracts. 
This would take about three minutes.
Moreover, the reader can export result to the local machine using docker volumn mount instruction `-v $HOME/localtmp:/dockertmp` as the following.
Once done, you can check the exported result file at the path `$HOME/localtmp/result.xlsx`.
Note that Due to the randomness feature of GA, the result may vary a little at different time.
The refered expected content of `$HOME/localtmp/result.xlsx` may be close to ![here](images/Screenshot%202022-05-03%20104202.png).
The first column (Alpha, Beta) represents `simratio, 1-simratio` respectively.
The fourth to eight columns shows the number of mined roles, the structure of mined roles, and the label of the mined roles, the ground truth (deployed roles) as well as the ratio (`len(MinedRoles)/len(DeployedRoles)`).
The rest columns show the result accuracy at different threshold that is dicussed in the paper.

```bash 
# from pulled docker image
docker run --rm liuyedocker/spcon-artifact benchmarkminer --limit 2
# either export result
docker run --rm -v $HOME/localtmp:/dockertmp liuyedocker/spcon-artifact benchmarkminer --limit 2 --output /dockertmp/result.xlsx
```

For complete experiement reproduction, the reader can generate all raw results appearing in the papers using the following instructions.
All results will be availabel at `$HOME/localtmp/result-0.4.xlsx`, `$HOME/localtmp/result-0.5.xlsx`,`$HOME/localtmp/result-0.6.xlsx`.
```bash 
# from pulled docker image
docker run --rm -v $HOME/localtmp:/dockertmp liuyedocker/spcon-artifact benchmarkminer --limit 50 --simratio 0.4 --output /dockertmp/result-0.4.xlsx
docker run --rm -v $HOME/localtmp:/dockertmp liuyedocker/spcon-artifact benchmarkminer --limit 50 --simratio 0.5 --output /dockertmp/result-0.5.xlsx
docker run --rm -v $HOME/localtmp:/dockertmp liuyedocker/spcon-artifact benchmarkminer --limit 50 --simratio 0.6 --output /dockertmp/result-0.6.xlsx
```

### Permission Bug Detection
SpCon detected permission bugs of smart contract from two benchmarks: [CVE smart contracts](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=smart+contract) and [SmartBugsWild](https://github.com/smartbugs/smartbugs-wild).
SpCon detected the bugs of nine contracts out of 17 access control CVE smart contracts.
For time saving, the reader can evaluate it using the following bash script.
```bash 
while read -r line; do docker run --rm liuyedocker/spcon-artifact spcon --eth_address $line >> execution.log 2>&1; done < CVE.list  
# this would take half an hour to execute all cases. 
grep "attack sequence" execution.log
# this would filter the found permission attack sequences and then the vulnerable contracts can also be directly identified.
"
CRITICAL:spcon.symExec:Permission Bug: find an attack sequence ['owned']
CRITICAL:spcon.symExec:Permission Bug: find an attack sequence ['owned', 'blacklistAccount']
...
"
```
## Reusability


