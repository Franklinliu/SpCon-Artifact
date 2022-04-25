from setuptools import setup, find_packages

setup(
    name="SpCon bug findder for smart contracts",
    description="SpCon is a history-driven testing framework written in Python 3.",
    url="https://github.com/Franklinliu/SpCon",
    author="Liu Ye",
    version="0.1.0",
    packages=find_packages(),
    python_requires=">=3.6",
    install_requires=[
        "prettytable>=0.7.2",
        "pysha3>=1.0.2",
        "crytic-compile==0.2.0",
        "manticore==0.3.7"
        "slither-analyzer>=0.8.0",
    ],
    # dependency_links=["git+https://github.com/crytic/crytic-compile.git@master#egg=crytic-compile"],
    license="AGPL-3.0",
    long_description=open("README.md").read(),
    entry_points={
        "console_scripts": [
            "spcon = spcontoolplus.__main__:main",
            "spcontoolsets =  spcontoolsets.__main__:main",
        ]
    },
)
