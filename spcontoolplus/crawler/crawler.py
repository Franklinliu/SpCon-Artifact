import os
import re 
import requests 
from urllib.request import Request, urlopen
from bs4 import BeautifulSoup as soup 
import pandas as pd 
import json
import csv 

import time
import cloudscraper
import math

from .BitQuery import main_collecttransaction_history


TransactionThreshold = 50
def getPage(url):
    # return getPage0(url)
    # return getPage1(url)
    return getPage2(url)

def getPage0(url):
    print(url)
    resp = requests.get(url)
    body = resp.content
    # print(body.decode("utf-8"))
    return body


def getPage1(url):
    print(url)
    resp = requests.get(url, proxies={"http": "socks5://127.0.0.1:20170", "https": "socks5://127.0.0.1:20170",
    "socks5": "socks5://127.0.0.1:20170"})
    body = resp.content
    # print(body.decode("utf-8"))
    return body

def getPage2(url):
    print(url)
    scraper = cloudscraper.create_scraper() # returns a CloudScraper instance
    # # Or: scraper = cloudscraper.CloudScraper()  # CloudScraper inherits from requests.Session
    # scraper.proxies = {"http": "socks5://127.0.0.1:20170", "https": "socks5://127.0.0.1:20170",
    # "socks5": "socks5://127.0.0.1:20170"}
    body = scraper.get(url).content
    return body 


def getAPIData(url):
    # req = Request(url, headers={'User-Agent': 'XYZ/3.0'})
    # body = urlopen(req, timeout=60).read()
    body = getPage(url)
    return json.loads(body.decode("utf8"))["result"]


def getLastTransaction(lasttxdate):
    days = 0
    if lasttxdate.find("days")!=-1:
        days = int(lasttxdate.split("days")[0].strip())
        # Calculate how many days ago of the last transaction
        return days
    else:
        return days 

def getInternalTransactions(address):
    startblock = 0
    url = "https://api.etherscan.io/api?module=account&action=txlistinternal&address={0}&startblock={1}&endblock=99999999&sort=asc&apikey={2}".format(address, startblock, apikey)
    transactions = []
    cnt = 0
    LIMIT = 3
    while cnt < LIMIT:
        ttransactions = getAPIData(url)
        if len(ttransactions)>0:
            startblock = str(int(ttransactions[-1]["blockNumber"])+1)
            cnt = cnt+1
            for transaction in ttransactions:
                if "gas" in transaction and "type" in transaction and \
                    int(transaction["gas"]) > 2300 and transaction["type"] == "call":
                    try:
                        weburl = f"https://etherscan.io/vmtrace?txhash={transaction['hash']}&type=parity#raw"
                        # print(soup(getPage(weburl), "html.parser").find(id="editor").text)
                        internals = json.loads("["+soup(getPage(weburl), "html.parser").find(id="editor").text+"]") 
                        for internal in internals:
                            if "to" in internal["action"] and internal["action"]["to"] == transaction["to"]:
                                transaction["input"] = internal["action"]["input"]
                        transactions.append(transaction)
                    except:
                        time.sleep(5)

            url = "https://api.etherscan.io/api?module=account&action=txlistinternal&address={0}&startblock={1}&endblock=99999999&sort=asc&apikey={2}".format(address, startblock, apikey)
        else:
            break
    # print(transactions)
    return transactions

def mergeTransactions(external_transactions: list, internal_transactions: list):
    
    def takeBlockNumber(elem):
        return int(elem["blockNumber"])

    transactions = external_transactions + internal_transactions
    
    transactions.sort(key=takeBlockNumber, reverse=False)
    
    print(f"Internal message calls (except fallback function): {len(transactions) - len(external_transactions)}")

    return transactions

def checkSelfDestructed(htmlbody):
    hasSelfDestructed = False
    if str(htmlbody).find("Self Destruct")!=-1:
        hasSelfDestructed = True
    
    print("Self Destruct: ", hasSelfDestructed)
    return hasSelfDestructed

def getETHHtmlBody(address):
    body = ""
    url = "https://etherscan.io/address/{0}".format(address)
    body = getPage(url)
    page_soup = soup(body, "html.parser")  
    body = page_soup
    title = page_soup.title.text
    print(title)
    for link in page_soup.find_all('a'):
        if link.get("title")=="Click to view full list":
            # print(link)
            # print(link.text)
            transactionNo = int(link.text.replace(",",""))
    body = page_soup.prettify()
    Transfers_info_table_1 = page_soup.find("div", {"class": "table-responsive"})
    df = pd.read_html(str(Transfers_info_table_1))[0]

    name, compiler_version, optimization, othersetting = tuple([div.text.strip() for div in page_soup.find_all("div", {"class": "col-7 col-lg-8"})])
    print(name, compiler_version, optimization, othersetting)
    divs = page_soup.select(".mb-4 ")
    # print(divs)
    arguments = "" 
    for div in divs:
        h4s = div.select("div h4")
        if len(h4s)>0:
            h4 = h4s[0]
            if h4 is not None and h4.text.find("Constructor Arguments")!=-1:
                arguments = div.select("div pre")[0].text.split("-----Decoded View---------------")[0]
                print(arguments)
                break    
    last_tx_date = df.iloc[0, 4]    
    is_killed = checkSelfDestructed(body)
    return is_killed, title, transactionNo, last_tx_date, name, compiler_version, optimization, othersetting, arguments

def getBSCHtmlBody(address):
    body = ""
    url = "https://bscscan.com/address/{0}".format(address)
    body = getPage(url)
    page_soup = soup(body, "html.parser")  
    body = page_soup
    title = page_soup.title.text
    print(title)
    for link in page_soup.find_all('a'):
        if link.get("title")=="Click to view full list":
            # print(link)
            # print(link.text)
            transactionNo = int(link.text.replace(",",""))
    body = page_soup.prettify()
    Transfers_info_table_1 = page_soup.find("div", {"class": "table-responsive"})
    df = pd.read_html(str(Transfers_info_table_1))[0]

    name, compiler_version, optimization, othersetting = tuple([div.text.strip() for div in page_soup.find_all("div", {"class": "col-7 col-lg-8"})])
    print(name, compiler_version, optimization, othersetting)
    divs = page_soup.select(".mb-4 ")
    # print(divs)
    arguments = "" 
    for div in divs:
        h4s = div.select("div h4")
        if len(h4s)>0:
            h4 = h4s[0]
            if h4 is not None and h4.text.find("Constructor Arguments")!=-1:
                arguments = div.select("div pre")[0].text.split("-----Decoded View---------------")[0]
                print(arguments)
                break    
    last_tx_date = df.iloc[0, 4]    
    is_killed = checkSelfDestructed(body)
    return is_killed, title, transactionNo, last_tx_date, name, compiler_version, optimization, othersetting, arguments


BLOCKCHAIN_ETH = "ETH"
BLOCKCHAIN_BSC = "BSC"

APIKEY_BLOCKCHAIN_ETH = "URF6R5PGNZ7CT6TTBU7M8NH5V8WRISHIZZ"
APIKEY_BLOCKCHAIN_BSC = "A4YZESUAIA4IGXSBK8D4NYQMUBMWTVAXN9"

WEBPAGE_FUNC_BLOCKCAHIN_ETH = getETHHtmlBody
WEBPAGE_FUNC_BLOCKCHAIN_BSC = getBSCHtmlBody

APIENDPOINT_BLOCKCHAIN_ETH = "https://api.etherscan.io/api"
APIENDPOINT_BLOCKCHAIN_BSC = "https://api.bscscan.com/api"

SOURCECODE_API_BLOCKCHAIN_ETH = "module=contract&action=getsourcecode&address={0}&apikey={1}"
SOURCECODE_API_BLOCKCHAIN_BSC = "module=contract&action=getsourcecode&address={0}&apikey={1}"

TXS_API_BLOCKCHAIN_ETH = "module=account&action=txlist&address={0}&startblock={1}&endblock=99999999&sort=asc&apikey={2}"
TXS_API_BLOCKCHAIN_BSC =  "module=account&action=txlist&address={0}&startblock={1}&endblock=99999999&sort=asc&apikey={2}"

ABI_API_BLOCKCHAIN_ETH = "module=contract&action=getabi&address={0}&apikey={1}"
ABI_API_BLOCKCHAIN_BSC = "module=contract&action=getabi&address={0}&apikey={1}"


Benchmark_csv_file = "./benchmark.csv"
def saveContract(address, name, compiler_version, arguments, transactionNo, sourcecode_file, transaction_file, abi_file, last_tx_date, is_killed, *args, **kwargs):
    global Benchmark_csv_file
    if not os.path.exists(Benchmark_csv_file):
        with open(Benchmark_csv_file, "w") as f:
            f.write( ", ".join(["address", "name", "compiler_version", "arguments", "transactionNo", "sourcecode_file", "transactions_file", "abi_file", "last txn date", "is_killed"]))
            f.write("\n")
    with open(Benchmark_csv_file, "a+") as f:
        f.write(",".join([address, name, compiler_version, arguments, str(transactionNo), sourcecode_file, transaction_file, abi_file, last_tx_date, "True" if is_killed else "False"]))
        f.write("\n")

class Crawler:
    def __init__(self, address, blockchain, workdir="./", date="latest"):
        self.address = address
        self.workdir = workdir
        self.date = date 
        if not os.path.exists(self.workdir):
            os.mkdir(self.workdir)
        if blockchain == BLOCKCHAIN_ETH:
            self.api_key = APIKEY_BLOCKCHAIN_ETH
            self.apiendpoint = APIENDPOINT_BLOCKCHAIN_ETH
            self.source_api = SOURCECODE_API_BLOCKCHAIN_ETH
            self.txs_api = TXS_API_BLOCKCHAIN_ETH
            self.abi_api = ABI_API_BLOCKCHAIN_ETH
            self.webpage_func = WEBPAGE_FUNC_BLOCKCAHIN_ETH
        elif blockchain == BLOCKCHAIN_BSC:
            self.api_key = APIKEY_BLOCKCHAIN_BSC
            self.apiendpoint = APIENDPOINT_BLOCKCHAIN_BSC
            self.source_api = SOURCECODE_API_BLOCKCHAIN_BSC
            self.txs_api = TXS_API_BLOCKCHAIN_BSC
            self.abi_api = ABI_API_BLOCKCHAIN_BSC
            self.webpage_func = WEBPAGE_FUNC_BLOCKCHAIN_BSC
    
    
    def readLocalSource(self):
        subdir = f"{self.workdir}/{self.address}"
        results = f"{subdir}/result.txt"
        if not os.path.exists(results):
            return False, None
        else:
            with open(results) as f:
                items = f.readlines()[-1].strip().split(",")
                address, name, compiler_version, arguments, transactionNo, transaction_file, sourcecode_file, abi_file, lasttxndate, is_killed = items
                return True, dict(address=address, name=name, compiler_version=compiler_version, arguments=arguments, transactionNo= transactionNo, transaction_file=transaction_file, sourcecode_file=sourcecode_file, abi_file= abi_file, lasttxndate = lasttxndate)
    
    def saveLocal(self, address, name, compiler_version, arguments, transactionNo, transaction_file, sourcecode_file, abi_file, last_tx_date, is_killed, *args, **kwargs):
        with open(f"{self.addressdir}/result.txt", "w") as f:
            f.write( ", ".join(["address", "name", "compiler_version", "arguments", "transactionNo", "transactions_file","sourcecode_file",  "abi_file", "last txn date", "is_killed"]))
            f.write("\n")
            f.write(",".join([address, name, compiler_version, arguments, str(transactionNo), transaction_file, sourcecode_file, abi_file, last_tx_date, "True" if is_killed else "False"]))

    def getSourceCode(self, name):
        if os.path.exists(f"{self.addressdir}/{name}.sol"):
            return f"{self.addressdir}/{name}.sol"
        url = self.apiendpoint+"?"+self.source_api.format(self.address, self.api_key)
        sourcecode = getAPIData(url)
        sourcecode = "\n".join([ contract["SourceCode"] for contract in sourcecode ])
        assert isinstance(sourcecode, str), "Error in source code; either network error or source code is unavailable!"
        with open(f"{self.addressdir}/{name}.sol", "w") as f:
            f.write(sourcecode.encode("charmap", "ignore").decode("utf8", "ignore"))
        return f"{self.addressdir}/{name}.sol"

    def getABI(self, name):
        if os.path.exists(f"{self.addressdir}/{name}.abi"):
            return f"{self.addressdir}/{name}.abi"
        url = self.apiendpoint+"?"+self.abi_api.format(self.address, self.api_key)
        abi = getAPIData(url)
        assert isinstance(abi, str), "Error in abi; either network error or abi is unavailable!"
        with open(f"{self.addressdir}/{name}.abi", "w") as f:
            f.write(str(abi))
        return f"{self.addressdir}/{name}.abi"


    def getWebPageStatistics(self):
        is_killed, title, transactionNo, last_tx_date, name, compiler_version, optimization, othersetting, arguments = self.webpage_func(self.address)
        return dict(address=self.address, name=name, compiler_version=compiler_version, arguments = arguments, last_tx_date = last_tx_date, transactionNo = transactionNo, is_killed = is_killed)

  
    def crawl(self):
        try:
            subdir = f"{self.workdir}/{self.address}"
            if os.path.exists(os.path.join(subdir, "result.txt")):
                boolflag, result = self.readLocalSource()
                result["transaction_file"]  = main_collecttransaction_history(address=self.address, workdir=self.workdir, date=self.date)
                if boolflag:
                    return result 
            
            if not os.path.exists(subdir):
                os.mkdir(subdir)

            self.addressdir = subdir 
            # 
            results = self.getWebPageStatistics()
            sourcecode = self.getSourceCode(name = results["name"])
            abi = self.getABI(name=results["name"])

            results["sourcecode_file"] = sourcecode
            results["abi_file"] = abi
            results["transaction_file"]  = main_collecttransaction_history(address=self.address, workdir=self.workdir, date=self.date)

            self.saveLocal(**results)

            saveContract(**results)
            return results
        except:
            raise Exception("crawling contract is not successful")

def main():
    contract_address = "0x00b113a5570a046c60ac8cfa4983b1dc1c780629"
    crawler = Crawler(address=contract_address, blockchain=BLOCKCHAIN_ETH)
    results = crawler.crawl()
    print(results)

if __name__ == "__main__":
    print("Hello world.")
    main()