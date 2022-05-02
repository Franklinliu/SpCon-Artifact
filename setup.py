from setuptools import setup, find_packages

setup(
    name="SpCon",
    description="SpCon is a history-driven testing framework written in Python 3.",
    url="https://github.com/Franklinliu/SpCon",
    author="Liu Ye",
    version="0.1.0",
    packages=find_packages(),
    python_requires=">=3.6",
    install_requires=[
        "prettytable>=0.7.2",
        "pysha3>=1.0.2",
        "crytic-compile==0.2.2",
        "manticore>=0.3.7",
        "slither-analyzer==0.8.0",
        "concepts == 0.9.2",
        "numpy",
        "pandas",
        "scipy",
        "web3",
        "cloudscraper",
        "prettytable",
        "requests",
        "timeout_decorator",
    ],
    # dependency_links=["git+https://github.com/crytic/crytic-compile.git@master#egg=crytic-compile"],
    license="AGPL-3.0",
    long_description=open("README.md").read(),
    entry_points={
        "console_scripts": [
            "spcon = spcon.__main__:main",
        ]
    },
)
