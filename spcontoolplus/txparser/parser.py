#!/usr/bin/env python3
# print('__file__={0:<35} | __name__={1:<20} | __package__={2:<20}'.format(__file__,__name__,str(__package__)))

from .decoder import  ContractAbi

class Parser:
    def parseAllTx(self, ABI_json, tx_receipts, has_contructor=True):
        ABI = ContractAbi(ABI_json)
        result = []
        if has_contructor:
            constructor = True
        else:
            constructor = False
        for tx_receipt in tx_receipts:
            # print(tx_receipt["isError"], tx_receipt["txreceipt_status"])
            if "txreceipt_status" in tx_receipt:
                success = (tx_receipt["isError"] == 0 and tx_receipt["txreceipt_status"]!=0) or (tx_receipt["isError"] == '0' and tx_receipt["txreceipt_status"]!='0')
            elif "errCode" in tx_receipt:
                success = tx_receipt["isError"] == '0' and tx_receipt["errCode"]==''
            if "hash" in tx_receipt:
                txHash = tx_receipt["hash"]
            elif "transactionHash" in tx_receipt:
                txHash = tx_receipt["transactionHash"]
            else:
                assert(False)
            # print(success)
            try:
                if success:
                    user, function, parameters, value, signature = self.parse(ABI, tx_receipt, is_constructor=constructor)
                    result.append((user, function, parameters, success, value, signature, txHash))
                    constructor = False
                    # print(user, function, success)
            except:
                constructor = False
                pass 
        return result

    def parse(self, ABI, tx_receipt, is_constructor):
        # print(tx_receipt)
        FALLBACK = "__fallback__"
        user = tx_receipt["from"]
        if "value" in tx_receipt:
            value = tx_receipt["value"]
        else:
            value = 0
        if tx_receipt["input"]=="constructor":
            function = tx_receipt["input"]
            parameters = ""
            signature = ""
            raise Exception("Sorry, constructors are not considered") 

        elif not is_constructor:
            method = ABI.decode_function(bytes.fromhex(tx_receipt["input"][2:]))
            function = method["name"]
            signature ="(" + ','.join([ input["type"] for input in method.inputs ]) + ")" 
            parameters = method.inputs
            # if function == FALLBACK:
            #     raise Exception("Sorry, __fallback__ function are not considered")
        else:
            method = ABI.decode_constructor(bytes.fromhex(tx_receipt["input"][2:]))
            function = "constructor" 
            signature ="(" + ','.join([ input["type"] for input in method.inputs ]) + ")" 
            parameters = method.inputs

            # raise Exception("Sorry, constructors are not considered") 
        
        return user, function, parameters, value,  signature
