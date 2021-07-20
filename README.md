### Properties Overview:

- By design, the Argennon blockchain is decoupled from cryptography. This makes Argennon a completely quantum safe
  cryptocurrency. If at any time, the cryptographic algorithms used become insecure, they could be easily upgraded.
  
- In Argennon, operations are authorized by **explicit** signatures. This eliminates the need for approval schemes or
  call back patterns and encourages developers to better utilize the capabilities of digital signatures.

- The Argennon Virtual Machine protects smart contracts from reentrancy by low level locks, while by using multiple call
  stacks, callback patterns could still be implemented to some extent.

- An Argennon smart contract can safely call external smart contracts. There is no way that a smart contract can affect
  its caller. Even the execution resources are separated and the called smart contract can not abort the execution of
  its caller by excessive gas usage.

- Most of the arithmetic in the Argennon Virtual Machine is done using floating point operations instead of unsigned
  integer operations. This way, there will be almost no need for a word size bigger than 64 bits. At the same time,
  operations will have a bounded fractional error in contrast to integer operations that could have an arbitrary
  fractional error.

- The Argennon Virtual Machine has a built-in standard library. This standard library provides a secure and convenient
  way for implementing many frequently used functionalities. In addition, this library is updatable through the Argennon
  governance system. This means that bugs or security vulnerabilities in the AVM standard library could be quickly
  patched and smart contracts that use this library, including non-updatable smart contracts, can benefit from
  improvements and bug fixes as well.

- Argennon standards are defined based on how a contract should use the AVM standard library and not only how its
  interface should look. As a result, users can expect certain type of behaviour from a contract which complies with an
  Argennon standard.

- Interaction with Argennon smart contract is done through conventional HTTP. This enables Argennon smart contracts to
  have HTTP based RESTful APIs, documented by standardized descriptions like OpenAPI. This way, any client, including
  clients being used for conventional centralized web services, will be able to use Argennon smart contracts, regardless
  of how the API is implemented internally.

- ARG, the main currency of the Argennon blockchain, is controlled by a smart contract. This eliminates the need for ARG
  wrappers and also makes the transfer logic of ARG more transparent and trustable.

- Memory architecture of the AVM completely hides the complexities of the Argennon blockchain. This enables AVM
  compatible programming languages to have a flavour completely similar to conventional programming languages. For
  instance, the Argon language, which is the primary AVM OOP language, supports *composition*, which is a very important
  OO design pattern.

- The Argennon Virtual Machine is a cloud based virtual machine and uses trust-less zero knowledge database servers as
  its persistence layer. At the same time, by using an AI powered clustering algorithm the AVM is able to keep the
  network usage manageable.

- Argennon uses a hybrid POS consensus protocol. A democratically elected committee of trusted delegates is responsible
  for minting new blocks and each block is validated by a large committee of normal validators. Every Argennon user is a
  member of at least one committee of validators. Thanks to the cloud based design of the AVM, transaction validation
  does not require a large storage space for storing the state of the Argennon blockchain. This way, being a validator
  does not require huge computational resources and everyone with an Argennon wallet can participate in the Argennon
  consensus protocol. This makes Argennon a truly democratic and decentralized blockchain.

- Argennon does not need shards because the validation of multiple blocks is done in parallel by different committees.
  Moreover, by using a dependency detection algorithm, Argennon is also able to parallelize transaction validation of a
  single block.

- The hybrid Argennon consensus protocol makes Argennon one of the most secure blockchains. Only one honest delegate can
  stop any attack against the integrity of the Argennon blockchain, and if all the delegates are malicious, as long as
  more than half of the Argennon total stake is controlled by honest users, the Argennon blockchain will preserve its
  consistency.

- The Argennon network relies on a **permission-less** network of ZK-EDB servers. A ZK-EDB server is a conventional data
  server which uses its computational and storage resources to help the Argennon network process transactions. A large
  portion of incentive rewards in the Argennon blockchain is devoted to ZK-EDB servers. This will incentivize the
  development of conventional networking, storage and computational hardware, which can benefit all areas of information
  technology. This contrasts with the approach of other blockchains that incentivize development of a totally useless
  technology of hash calculation.

<!---
*α* =  − ln (1 − *M*<sub>*n* + *k*</sub>/*X*) / *n*
<img src="https://render.githubusercontent.com/render/math?math=e^{i \pi} = -1">
h<sub>&theta;</sub>(x) = &pi;<sub>o</sub> x + &theta;<sub>1</sub>x
--->
