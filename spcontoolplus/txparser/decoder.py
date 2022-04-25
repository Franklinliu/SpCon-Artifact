# -*- coding: UTF-8 -*-
"""
Utility functions for decoding inputs/arguments based on contract json abi definitions
Original Source: https://github.com/tintinweb/ethereum-input-decoder
Note: we modify the code For research purpose.
"""

from eth_abi.abi import decode_abi
import eth_abi.exceptions
import binascii
import requests
from sha3 import keccak_256

class ContractAbi(object):
    """
    Utility Class to encapsulate a contracts ABI
    """
    def __init__(self, jsonabi):
        self.abi = jsonabi
        self.signatures = {}
        self._prepare_abi(jsonabi)

    def _add_method_abi(self, jsonmethodabi):
        self.abi.append(jsonmethodabi)  # add the json-method-abi to the internal json repr
        self._prepare_abi(self.abi)  # re-init internal structures

    def _prepare_abi(self, jsonabi):
        """
        Prepare the contract json abi for sighash lookups and fast access

        :param jsonabi: contracts abi in json format
        :return:
        """
        # print(jsonabi)
        self.signatures = {}
        for element_description in jsonabi:
            abi_e = AbiMethod(element_description)
            # if abi_e.get("type") == "constructor":
            if abi_e.get("type") == "constructor":
                self.signatures[b"__constructor__"] = abi_e
            elif abi_e.get("type") == "fallback":
                abi_e.setdefault("inputs", [])
                self.signatures[b"__fallback__"] = abi_e
            elif abi_e.get("type") == "function":
                # function and signature present
                # todo: we could generate the sighash ourselves? requires keccak256
                self.signatures[abi_e.signature()] = abi_e
            elif abi_e.get("type") == "event":
                self.signatures[b"__event__"] = abi_e
            elif abi_e.get("type") == "receive":
                pass 
            else:
                raise Exception("Invalid abi type: %s - %s - %s" % (abi_e.get("type"),
                                                                    element_description, abi_e))

    def decode_constructor(self, s):
        """
        Describe the input bytesequence (constructor arguments) s based on the loaded contract
         abi definition

        :param s: bytes constructor arguments
        :return: AbiMethod instance
        """
        method = self.signatures.get(b"__constructor__")
        if not method:
            # constructor not available
            m = AbiMethod({"type": "constructor", "name": "", "inputs": [], "outputs": []})
            return m

        types_def = method["inputs"]
        types = [t.get("type") for t in types_def]
        names = [t.get("name") for t in types_def]

        if not len(s):
            values = len(types) * ["<nA>"]
        else:
            values = decode_abi(types, s)

        # (type, name, data)
        method.inputs = [{"type": t, "name": n, "data": v} for t, n, v in list(
            zip(types, names, values))]
        return method

    def decode_function(self, s):
        """
        Describe the input bytesequence s based on the loaded contract abi definition

        :param s: bytes input
        :return: AbiMethod instance
        """
        signatures = self.signatures.items()
        # print(f"s: {s}")
        # print(f"signature: {signatures}")
        for sighash, method in signatures:
            if sighash is None or sighash.startswith(b"__"):
                continue  # skip constructor
            # print(binascii.hexlify(bytearray(s))[:8], binascii.hexlify(bytearray(sighash)), method.get("name"))
            if s.startswith(sighash):
                # print(binascii.hexlify(bytearray(s))[:8], binascii.hexlify(bytearray(sighash)), method.get("name"))
                s = s[len(sighash):]
                types_def = self.signatures.get(sighash)["inputs"]
                types = [t.get("type") for t in types_def]
                names = [t.get("name") for t in types_def]

                if not len(s):
                    values = len(types) * ["<nA>"]
                else:
                    values = decode_abi(types, s)

                # (type, name, data)
                method.inputs = [{"type": t, "name": n, "data": v} for t, n, v in list(
                    zip(types, names, values))]
                return method
        else:
            method = AbiMethod({"type": "fallback",
                                "name": "__fallback__",
                                "inputs": [], "outputs": []})
            types_def = self.signatures.get(b"__fallback__", {"inputs": []})["inputs"]
            types = [t.get("type") for t in types_def]
            names = [t.get("name") for t in types_def]

            values = decode_abi(types, s)

            # (type, name, data)
            method.inputs = [{"type": t, "name": n, "data": v} for t, n, v in list(
                zip(types, names, values))]
            return method


class AbiMethod(dict):
    """
    Abstraction for an abi method that easily serializes to a human readable format.
    The object itself is an extended dictionary for easy access.
    """
    def __init__(self,  *args, **kwargs):
        super().__init__(*args, **kwargs)
        # if "input" in self:
        #     print(self)
        #     self.inputs = self["input"]
        # else:
        # print(self.get("inputs"))
        self.inputs = self.get("inputs")

    def __str__(self):
        return self.describe()

    def describe(self):
        """
        :return: string representation of the methods input decoded with the set abi
        """
        outputs = ", ".join(["(%s) %s" % (o.get("type"), o.get("name")) for o in
                             self["outputs"]]) if self.get("outputs") else ""
        inputs = ", ".join(["(%s) %s = %r" % (i.get("type"), i.get("name"), i.get("data")) for i in
                            self.inputs]) if self.inputs else ""
        return "%s %s %s returns %s" % (self.get("type"), self.get("name"), "(%s)" % inputs
            if inputs else "()", "(%s)" % outputs if outputs else "()")

    def signature(self):
        input_str = ",".join(["%s" % i.get("type") for i in
                            self.inputs]) if self.inputs else ""
        full_sig = self.get("name") +"("+input_str +")"
        # print(full_sig)
        k = keccak_256()
        k.update(full_sig.encode("utf8"))
        function_selector = k.hexdigest()
        # print(full_sig, function_selector, function_selector[:8])
        return bytes.fromhex(function_selector[:8])
