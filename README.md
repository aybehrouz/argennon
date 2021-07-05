### Properties Overview:

- By design, the Argennon blockchain is decoupled from cryptography. This makes Argennon a completely quantum safe
  cryptocurrency. If the cryptographic algorithms used become insecure, they could be easily upgraded.

- The Argennon Virtual Machine protects smart contracts from reentrancy by using multiple call stacks, while callback
  patterns could still be implemented to some extent.

- Most of the arithmetic in the Argennon Virtual Machine is done using floating point operations instead of unsigned
  integer operations. This way, there will be almost no need for a word size bigger than 64 bits. At the same time
  operations will have a bounded fractional error in contrast with integer operations that have an infinite fractional
  error.

- The Argennon Virtual Machine has a standard library. This standard library provides a secure and convenient way for
  implementing many frequently used functionalities. In addition, this library is updatable through the Argennon
  governance system, and non-updatable smart contracts that use the avm library can benefit from improvements and bug
  fixes as well.

- Argennon standards are defined based on how a contract should use the AVM standard library and not only how its
  interface should look. As a result, users can expect certain type of behaviour from a contract which complies with an
  Argennon standard.

- ARG, the main currency of the Argennon blockchain, is controlled by a smart contract. This eliminates the need for ARG
  wrappers and also makes the transfer logic of ARG more transparent and trustable.

- Memory architecture of the AVM completely hides the complexities of the Argennon blockchain. This enables AVM
  languages to have a flavour completely similar to conventional programming languages. For instance, the Argon
  language, which is the primary AVM OO programming language, supports *composition*, which is a very important OO
  design pattern.

- The Argennon Virtual Machine is a cloud based virtual machine and uses zero knowledge database servers as its
  persistence layer. By using a smart clustering algorithm the AVM is able to keep the network usage manageable.

- Argennon uses a hybrid consensus protocol. A democratically elected committee of delegates is responsible for minting
  new blocks and each block is validated by a committee of validators. Every Argennon user is a member of at least one
  committee of validators. Thanks to the cloud based design of the AVM, transaction validation does not require a large
  storage space for storing the state of the Argennon blockchain. This way being a validator does not require huge
  computational resources and everyone with an Argennon wallet can participate in the Argennon consensus protocol.

- Argennon does not need shards because the validation of multiple blocks can be done in parallel by different
  committees. Moreover, by using a dependency detection algorithm, Argennon is also able to parallelize transaction
  validation of a single block.

- the hybrid Argennon consensus protocol makes Argennon one of the most secure blockchains. Only one honest delegate can
  stop any type of attack against the integrity of the Argennon blockchain, and if all the delegates are malicious as
  long as more than half of the Argennon total stake is controlled by honest users the Argennon blockchain will be
  completely safe.

<!---
*α* =  − ln (1 − *M*<sub>*n* + *k*</sub>/*X*) / *n*
<img src="https://render.githubusercontent.com/render/math?math=e^{i \pi} = -1">
h<sub>&theta;</sub>(x) = &pi;<sub>o</sub> x + &theta;<sub>1</sub>x
--->
