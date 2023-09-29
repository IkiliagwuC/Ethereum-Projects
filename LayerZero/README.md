# What is LayerZero ?

#### Introduction
The proliferation of blockchains has given developers a
variety of platforms on which to run their smart contracts based on application features and requirements for
throughput, security, and cost. However, a consequence
of this freedom is severe fragmentation; Each chain is
isolated, forcing users to silo their liquidity and limiting options to move liquidity and state between walled
ecosystems.
This paper presents LayerZero, the first trustless omnichain interoperability protocol, which provides a powerful, low level communication primitive upon which a
diverse set of cross-chain applications can be built. Using this new primitive, developers can implement seamless inter-chain applications like a cross-chain DEX or
multi-chain yield aggregator without having to rely on
a trusted custodian or intermediate transactions

`LayerZero` is an Omnichain communication, interoperability, decentralized infrastructure, designed for lightweight message passing across chains. LayerZero provides authentic and guaranteed message delivery with configurable trustlessness. The protocol is implemented as a set of efficient, non-upgradable smart contracts.
[LayerZero Documentation](https://layerzero.gitbook.io/docs/)

## Basic Architecture
Terms to fully understand how LayerZero works
### Oracles
- Oracles perform the role of securing LayerZero messaging Protocol by moving Data between chains

- Each oracle has the task of moving a requested `block header` from a `source chain` to a `destination chain` 
- An oracle works in tandem with a `Relayer`
- Each User Application(UA) contract built on LayerZero will work without configuration using defaults, but a UA will also be able to configure its own Oracle and Relayer.

### Relayers
- Relayers perform a critical role in the LayerZero message protocol by delivering messages.
- Relayers work in tandem with an `Oracle` to transmit messages between chains.
- By default,  will use the LayerZero Relayer. This means you do not need to run your own Relayer.
- You can read the LayerZero Documentation on how to set up a custom Relayer.


### Code
This code project Examines how LayerZero can be used to send a simple crossChain message in solidity
1. The LayerZero interface allows us use and interact with contract that will help us send the crosschain messages. To send crosschain messages we will use an endpoint to send() from the source chain and lZReceive() to receive the message on the destination chain. In order to use it, we need to import the interface from the layerZero repository
[LayerZero interface]()
