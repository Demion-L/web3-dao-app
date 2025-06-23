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

# Load .env variables

```shell
source .env
```

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url sepolia --broadcast --verify
```

### Addresses of deployed to Sepolia testnet contracts

```
  Token deployed to: 0x873e907D3E7e3c5aB020afD37973624f7523165c
  TimeLock deployed to: 0x3cAD09734AeAe05ab2562E1FE06Eb64Ec1577b39
  Governor deployed to: 0x8cc4f78e35E98391bb3BE931EDAF36cCd8D737Fa
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
