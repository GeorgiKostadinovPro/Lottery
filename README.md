## Lottery
<p>Lottery is a smart contract project for automated lottery.</p>
<p>EOA or Contracts can enter a lottery with entrancy fee.</p>
<p>The winner is chosen on a random principle after sertain amount of time has passed.</p>
<p>When the process of choosing a winner begins, no account is permitted to participate (the lottery is closed).</p>
<p>After picking a winner he receives his rewards and the lottery is open for participation again.</p>
<p>The Lottery is fully automated to open and choose winner by itself. There is no human intervention and no outside factors.</p>

<ul>
    <strong>Important:</strong>
    <li>Not real ether or private keys are used.</li>
    <li>This project can be deployed both to an in-memory local blockchain like Anvil or Sepolia Testnet.</li>
    <li>If you want to use Sepolia Testnet or any other, you have to make an account and use your api keys.</li>
    <li>If you want to test with Sepolia you have to have some Sepolia Test Eth which can be aquired from a Faucet.</li>
    <li>Anvil would be easier to test with since it is a local Ethereum node provided by Foundry.</li>
</ul>

<p></p>

<p>For further info, please read the whole file, so you can interact with the project efficiently.</p>

<p><strong>NOTE:</strong> you need to have WSL and Ubuntu in order to execute the project on Windows.</p>

## Tech Stack

<p>
  <img alt="Static Badge" src="https://img.shields.io/badge/Solidity-%E2%9C%93-black">
  <img alt="Static Badge" src="https://img.shields.io/badge/Foundry-%E2%9C%93-%23C21325">
  <img alt="Static Badge" src="https://img.shields.io/badge/Chainlink-%E2%9C%93-blue">
  <img alt="Static Badge" src="https://img.shields.io/badge/Chainlink Automation-%E2%9C%93-lightblue">
</p>

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Clone
```shell
$ git clone --recurse-submodules https://github.com/GeorgiKostadinovPro/Lottery
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployFundMe.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

<p>--rpc-url - either Anvil url or actual test network url like Sepolia.</p>
<p>--private-key - the same goes for the private keys.</p>

### Scripts

```shell
$ forge script script/Interactions.s.sol:Fund --rpc-url <your_rpc_url> --private-key <your_private_key>
```
```shell
$ forge script script/Interactions.s.sol:Withdraw --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
