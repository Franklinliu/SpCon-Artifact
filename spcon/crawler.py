import subprocess
import requests
import cloudscraper
import json 
import os 

def getPage(url):
    # return getPage0(url)
    # return getPage1(url)
    return getPage2(url)

def getPage0(url):
    # print(url)
    resp = requests.get(url)
    body = resp.content
    return body


def getPage1(url):
    print(url)
    resp = requests.get(url, proxies={"http": "socks5://127.0.0.1:20170", "https": "socks5://127.0.0.1:20170",
    "socks5": "socks5://127.0.0.1:20170"})
    body = resp.content
    return body

# returns a CloudScraper instance
scraper = cloudscraper.create_scraper() 
def getPage2(url):
    global scraper
    # print(url)
    body = scraper.get(url).content
    return body 


def getAPIData(url):
    body = getPage(url)
    return json.loads(body.decode("utf8"))["result"]


api_endpoint = "https://api.etherscan.io/api"
source_api = "module=contract&action=getsourcecode&address={0}&apikey={1}"


def filtercompilerversion(compiler_version):
    if compiler_version.find("commit")!=-1:
        compiler_version = compiler_version.split("+commit")[0].split("v")[1]
    if compiler_version.find("night")!=-1:
        compiler_version = compiler_version.split("-night")[0]
        if compiler_version.find("v")!=-1:
            compiler_version = compiler_version.split("v")[1]
    return compiler_version

def installSolc(solcVersion):
    solcVersion = filtercompilerversion(solcVersion)
    subprocess.run(["solc-select","install", solcVersion])
    # print(cp)
    subprocess.run(["solc-select","use", solcVersion])
    
def getSourceCode(address, api_key):
    global api_endpoint, source_api
    url = api_endpoint+"?"+source_api.format(address, api_key)
    sourcecode = getAPIData(url)
    contractName = sourcecode[0]["ContractName"]
    compilerVersion = sourcecode[0]["CompilerVersion"]
    constructorArguments = sourcecode[0]["ConstructorArguments"]
    solc_version = filtercompilerversion(compiler_version=compilerVersion)
    installSolc(solcVersion=solc_version)
    sourcecode = "\n".join([ contract["SourceCode"] for contract in sourcecode ])
    if not os.path.exists("./etherscan"):
        os.mkdir("./etherscan")
    with open(f"./etherscan/{address}-{contractName}.sol", "w") as f:
        f.write(sourcecode.encode("charmap", "ignore").decode("utf8", "ignore"))
    return contractName, f"etherscan/{address}-{contractName}.sol"
