## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

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

### Deploy Foundry

1. Switch to the /foundry and run

```shell
$ anvil
```

2. From /foundry folder run next command to deploy all contracts

```shell
$ forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast -vvvv
```

### Deploy to Sepolia tesnet (dry)

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url sepolia
```

### Deploy to Sepolia tesnet

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url sepolia --broadcast --verify
```

### Addresses of deployed to Sepolia testnet contracts

```
  Token deployed to: 0x4B5A4ACDaBCb362780350Aca69Fc80EE4Acb1352
  TimeLock deployed to: 0xe2b5beB808b4626ea6Ab383Ca461fe1548417691
  Governor deployed to: 0xa4aE57AE0db3fD34D8468C82eE5eA64207878aD4
```

### Deploy Hardhat

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
