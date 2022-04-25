
#!/usr/bin/python
# -*- coding: utf-8 -*-
from asyncio import sleep
from itertools import count
from logging import lastResort
from typing import Counter
import requests
from string import Template
import json 
import datetime 
import os


def run_query(query, variables):  # A simple function to use requests.post to make the API call.
    headers = {'X-API-KEY': 'BQYEtWs7QzCdCwkJKVhmTDp3RFTWAUEP'}
    request = requests.post('https://graphql.bitquery.io/',
                            json={'query': query, "variables":variables}, headers=headers)
    if request.status_code == 200:
        ret = request.json()
        return ret
    else:
        print(request.json())
        raise Exception('Query failed and return code is {}.      {}'.format(request.status_code,
                        query))

def main_collecttransaction_history(address, workdir="./", date="latest"):
    today = datetime.date.today()
    latestday = today.strftime("%Y-%m-%d")
    # print(latestday)
    # print(date)
    if date=="latest":
        date = latestday 
    print(date)
    if not os.path.exists(os.path.join(workdir, address)):
      os.mkdir(os.path.join(workdir, address))
    else:
      pass
    # The GraphQL query
    variablesObj = {
      "limit": 1,
      "network": "ethereum",
      "address": address,
      "date": date
    }
    variables = json.dumps(variablesObj)
    query_user_statistics = """
    query ($network: EthereumNetwork!, $address: String!, $limit: Int, $date: ISO8601DateTime){
      ethereum(network: $network) {
        smartContractCalls(
          options: {limit: $limit}
          smartContractAddress: {is: $address}
          date: {before: $date}
        ) {
          count(
            uniq: callers
          )
        }
      }
    }
    """
    counter = 0
    while counter<5:
        result2 = run_query(query_user_statistics, variables)  # Execute the query
        counter += 1
        if "data" not in result2:
            sleep(20)
            continue 
        else:
            break 

    query_call_statistics = """
    query ($network: EthereumNetwork!, $address: String!, $limit: Int, $date: ISO8601DateTime){
      ethereum(network: $network) {
        smartContractCalls(
          options: {limit: $limit}
          smartContractAddress: {is: $address}
           date: {before: $date}
        ) {
          count(
            uniq: calls
          )
        }
      }
    }
    """ 
    counter = 0
    while counter<5:
        result3 = run_query(query_call_statistics, variables)  # Execute the query
        counter += 1
        if "data" not in result3:
            sleep(20)
            continue 
        else:
            break 
    variablesObj["limit"]  =  result3["data"]["ethereum"]["smartContractCalls"][0]["count"]
    variablesObj["limit"] =  variablesObj["limit"] if variablesObj["limit"]<10000 else 10000
    print(variablesObj)
    variables = json.dumps(variablesObj)
    query_user_all2 = """
    query ($network: EthereumNetwork!, $address: String!, $limit: Int, $date: ISO8601DateTime){
      ethereum(network: $network) {
        smartContractCalls(
          options: {limit: $limit}
          smartContractAddress: {is: $address}
          date: {before: $date}
        ) {
          smartContractMethod {
            name
            signature
            signatureHash
          }
          caller {
            address
          }
          success
          count
        }
      }
    }
    """
    counter = 0
    while counter<5:
      result12 = run_query(query_user_all2, variables)  # Execute the query
      counter += 1
      if "data" not in result12:
            sleep(10)
            continue 
      else:
            break 

    with open("{0}/{1}/all_txs.json".format(workdir, address), "w") as f:
        json.dump(result12, f)

    with open("{0}/{1}/user_statistics.json".format(workdir, address), "w") as f:
        json.dump(result2, f)

    with open("{0}/{1}/call_statistics.json".format(workdir, address), "w") as f:
        json.dump(result3, f)
    if variablesObj["limit"] >= 50:
        return "{0}/{1}/all_txs.json".format(workdir, address)
    else:
        return None 
    
if __name__ == "__main__":
    main_collecttransaction_history(address="0xcc13fc627effd6e35d2d2706ea3c4d7396c610ea", workdir="./")