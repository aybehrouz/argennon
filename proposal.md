## Introduction

The Algorand Virtual Machine (AVM) is an abstract computing machine for executing Algorand's smart contracts. It is
designed in a way that it could be efficiently implemented in either hardware or software.

## The Structure of the Algorand Virtual Machine

...

### Data Types

The Algorand Virtual Machine expects that all type checking is done prior to run time, typically by a compiler, and does
not have to be done by the Algorand Virtual Machine itself.

The instruction set of the Algorand Virtual Machine distinguishes its operand types using instructions intended to
operate on values of specific types. For instance, `iadd` assumes that its operands are two 64-bit integers.

### The `PC` Register

....

### Call Stack

A call stack contains the information that is needed for restoring the state of the invoker of a method.

### Memory Unit

The Algorand Virtual Machine has a byte addressable memory which is divided into separate segments. Every segment
belongs to a smart contract that has a unique `applicationID`. The AVM always has a single working memory segment and
memory locations outside its current working segment can not be accessed. The only instructions that can change the
current working segment are `invoke_external`, `athrow` and return instructions.

Every smart contract has its own memory segment. Hence, there is no way for a smart contract to access another smart
contract's memory. Interaction between smart contracts is done using `invoke_external` instruction. A smart contract can
invoke methods of another smart contract by this instruction.

A memory segment consists of five data areas:

- Code Area
- Constant Area
- Local Frame
- Operand Stack
- Heap

All data areas except operand stack, have their own address space which starts from 0. Operand stack is a
last-in-first-out (LIFO) stack and is not addressable. Every memory access instruction operates on its specific data
areas.

#### Code Area

The code area of a segment contains the byte-code of the smart contract which owns that segment. The AVM has no
instructions for manipulating the code area. **Installing, removing and updating smart contracts need to be done
externally.**

#### Constant Area

The constant area of a segment contains several kinds of constants, ranging from user defined constants to method
address tables. A method address table stores method locations in the code area and their access type. The access type
of a method can be either `public` or `private`. The AVM has no instructions for modifying the constant area.

_Only public methods can be invoked by `invoke_external` instruction._

#### Local Frame

A local frame is used to store methods parameters and local variables. A new frame is created each time a method is
invoked. A frame is destroyed when its method invocation completes, whether the completion is normal or abrupt.

#### Operand Stack

Every time a local frame is created, a corresponding empty last-in-first-out (LIFO) stack is created too. AVM
instructions take operands from the operand stack, operate on them, and push the result back onto the operand stack. An
operand stack is destroyed when its owner method completes, whether that completion is normal or abrupt.

#### Heap

The heap of a segment is a persistent memory area which is divided into pages. Each page can be referenced by an index
that starts from 0. Memory locations inside every page have a separate address space that starts from 0. In other words,
the address of every memory location inside a heap is a pair of indices: `(pageIndex, offset)`. Pages of a heap do not
need to be equally sized.

_The reason behind this paged design is that the heap is usually persisted using a block device. A heap with a paged
structure could expose the underlying block based nature of the persistence layer to the application layer. In this way,
the compiler or the programmer could better optimize the code for the persistence layer._

## Instruction Set Summary

An Algorand Virtual Machine instruction consists of a **one-byte** opcode specifying the operation to be performed,
followed by zero or more operands supplying arguments or data that are used by the operation. **The number and size of
the operands are determined solely by the opcode.**

### Method Invocation

The Algorand Virtual Machine has three types of method invocation:

- `invoke_internal` invokes a method from the current running smart contract.
- `invoke_external` invokes a `public` method from another smart contract. It will change the current memory segment to
  the segment of the invoked smart contract.
- `invoke_native` invokes a method that is not hosted by the Algorand virtual machine. By this instruction, high
  performance native methods of a hosting machine could become available to AVM smart contracts.

_In the future, we may need to add special instructions for invoking interface and virtual methods..._

Each time a method is invoked a new local frame and operand stack is created. The Algorand Virtual Machine
uses [local frames](#local-frame) to pass parameters on method invocation. On method invocation, any parameters are
passed in consecutive local variables stored in the method's local frame starting from local variable 0. The invoker of
a method writes the parameters in the local frame of the invoked method using `arg` instructions.

### Exceptions

An exception is thrown programmatically using the `athrow` instruction. Exceptions can also be thrown by various
Algorand Virtual Machine instructions if they detect an abnormal condition. Some exceptions are not catchable and will
always abort the execution of the smart contract.

### Method Invocation Completion

A method invocation completes normally if that invocation does not cause an exception to be thrown, either directly from
the AVM or as a result of executing an explicit throw statement. If the invocation of the current method completes
normally, then a value may be returned to the invoking method. This occurs when the invoked method executes one of the
return instructions, the choice of which must be appropriate for the type of the value being returned (if any).
Execution then continues normally in the invoking method's local frame with the returned value (if any) pushed onto the
operand stack.

A method invocation completes abruptly if an exceptions is thrown and is not caught by the current method. A method
invocation that completes abruptly never returns a value to its invoker.

When a method completes, whether normally or abruptly, the call stack is used to restore the state of the invoker,
including its local frame and operand stack, with the `PC` register appropriately restored and incremented to skip past
the method invocation instruction. If the invoker was another smart contract, i.e. the invocation was made by
an `invoke_external` instruction, the current memory segment will be changed to the invoker's segment.

A thrown exception causes methods in the call stack to complete **abruptly** one by one, as long as the `PC` register is
not pointing to a `catch` instruction. The `catch` instruction acts like a branch instruction that branches only if an
exception is caught.  **When an external method invocation completes abruptly, before changing the current segment, all
changes made to the heap area will be rolled back.**

_By using the `athrow` instruction properly, a programmer can make any method act like an atomic operation._

### Authorizing Operations

In blockchain applications, we usually need to authorize certain operations. For example, for sending an asset from a
user to another user, first we need to make sure that the sender has authorized this operation. The Algorand virtual
machine has no built in mechanism for authorizing operations, but it provides a rich set of cryptographic instructions
for validating signatures and cryptographic entities. By using these instructions and passing signatures as parameters
to methods a programmer can implement the required logic for authorizing any operation.

_The Algorand virtual machine has no instructions for issuing cryptographic signatures._

In addition to signatures, a method can verify its invoker by using `get_parent` instruction. This instruction gets
the `applicationID` of the smart contract that is one level deeper than the current smart contract in the call stack. In
other words, it gives the smart contract that has invoked the current smart contract. (if any)

### Heap Allocation Instructions

...

## Implementation

### Persistence

For implementing the persistence layer of the AVM, we assume that we have access to an updatable zero-knowledge
elementary database (ZK-EDB) with the following properties:

- ZK-EDB contains a mapping from a set of keys to a set of values.
- Every state of the database has a commitment C.
- ZK-EDB has a method (D, p) = DB.get(x), where x is a key and D is the associated value with x and p is a proof.
- A user can use C and p to verify that D is really associated with x, and D is not altered. Consequently, a user who
  can obtain C from a trusted source do not need to trust the ZK-EDB.
- Having p and C a user can compute the commitment C' for the database in which D' is associated with x instead of D.

We use a ZK-EDB for storing the AVM heap. We include the commitment of the current state of this DB in every block of
the Algorand blockchain, so ZK-EDB servers need not be trusted servers.

Every page of AVM heap will be stored with a key of the form: `applicationID|pageIndex` (the `|` operator concatenates
two numbers). Nodes do not keep a full copy of the AVM heap and for validating block certificates or emulating the AVM (
i.e. validating transactions) they need to connect to a ZK-EDB and retrieve the required pages of AVM heap. For better
performance, **nodes keep a cache of heap pages to reduce the amount of ZK-EDB access**.

We also use a ZK-EDB for storing the code area of each segment, and we include the commitment of this DB in every block.
Every code area will be divided into blocks and every block will be stored in the DB with `applicationID|blockID` as its
key. Like heap pages, nodes keep a cache of code area blocks.

_Unlike heap pages, the AVM is not aware of different blocks of a code area._

### Transactions

Algorand has four types of transaction:

- `avmCall` essentially is an `invoke_external` instruction that invokes a method from an AVM smart contract. Users
  interact with AVM smart contracts using these transactions. Transferring all assets, including ALGOs, is done by these
  transactions.
- `installApp` installs an AVM smart contract and determines the update policy of the smart contract: if the contract is
  updatable or not, the accounts that can update or uninstall the contract, and so on.
- `unInstallApp` removes an AVM smart contract.
- `updateApp` updates an AVM smart contract.

All types of Algorand transactions contain an `invoke_external` instruction which calls a special method from ALGO smart
contract that transfers the proposed fee of the transaction in ALGOs from a sender account to the fee sink accounts.

Every transaction is required to exactly specify what heap pages or code area blocks it will access. This enables
validators to start retrieving the required memory blocks from available ZK-EDB servers as soon as they see a
transaction, and they won't need to wait for receiving the new proposed block. A transaction that tries to access a
memory block that is not included in its access lists, will be rejected. Users could
use [smart contract oracles](#smart-contract-oracle)
to predict the list of memory blocks their transactions need.

### Blockchain

Every block of the Algorand blockchain corresponds to a set of transactions. We store the commitment of this transaction
set in every block, but we don't keep the set itself. To be able to detect replay attacks, we require every signature
that a user creates to have a nonce. This nonce consists of the issuance round of the signature and a sequence
number: `(issuance, sequence)`. When a user creates more than one signature in a round, he must sequence his signatures
starting from 0 (i.e. the sequence number restarts from 0 in every round). We define a maximum lifetime for signatures,
so a signature is invalid if `currentRound - issuance > maxLifeTime` or if a signature of the same user with a bigger or
equal nonce is already used (i.e. is recorded in the blockchain). A nonce is bigger than another nonce if it has an
older issuance. If two nonces have an equal issuance, the nonce with the bigger sequence number will be considered
bigger.

To be able to detect invalid signatures, we keep the maximum nonce of used digital signatures per user. When the
difference between `issuance` component of this nonce and the current round becomes bigger than the maximum allowed
lifetime of a signature, this information can be safely deleted. **As a result, we will not have the problem of "
unremovable empty accounts" like Ethereum.**

The only information that Algorand nodes are required to store is **the most recent block** of the Algorand blockchain.
Every block of the Algorand blockchain contains the following information:

| Block |
| ---- |
| commitment to the ZK-EDB storing heap pages |
| commitment to the ZK-EDB storing code areas |
| commitment to the set of transactions |
| previous block hash |
| random seed |

For confirming a new block, nodes that are not validators only need to verify the block certificate. For verifying a
block certificate, a node needs to know the ALGO balances of validators, but it doesn't need to emulate the AVM
execution.

On the other hand, nodes that are chosen to be validators, for validating a new block, need to emulate the execution of
the Algorand virtual machine. To do so, first they retrieve all heap pages and code area blocks they need from available
ZK-EDBs. Then, they emulate the execution of AVM instructions and validate all the transactions included in the new
block. This will modify some pages of the AVM memory, so they update the ZK-EDB commitments based on the modified pages
and verify the commitments included in the new block. Validators also calculate and verify the commitment to the new
block's transaction set.

_Validators do not need to write the modified pages back to ZK-EDBs. ZK-EDBs will receive the new block, and they will
update their database by emulating the AVM execution._

### Incentive mechanism

#### Transaction Fee

Every transaction in the Algorand blockchain starts with an `invoke_external` instruction which calls a special method
from ALGO smart contract. This method will transfer the proposed fee of the transaction in ALGOs from a sender account
to the fee sink accounts. Algorand has two fee sink accounts: `execFeeSink` collects execution fees and `dbFeeSink`
collects fees for ZK-EDBs. The Protocol decides how to distribute the transaction fee between these two fee sink
accounts.

_For many circumstances, dividing the fee based on a constant ratio between the two fee sinks seems to be a reasonable
choice._

When a block is added to the blockchain, the proposer of that block will receive a share of the block fees.
Consequently, a block proposer is always incentivized to include more transactions in his block. However, if he puts too
many transactions in his block and the validation of the block becomes too difficult, some validators may not be able to
validate all transactions in the required time. In this case, the network may reach consensus on an empty block, and the
proposer will not receive any fees. So a proposer is incentivized to use network transaction capacity optimally.

On the other hand, we believe that the proposer does not have enough incentives for optimizing the storage size of the
transaction set. Therefore, we require that **the size of the transaction set of every block in bytes be lower than a
certain threshold.**

Validators need to spend resources for validating transactions. When a validator starts the emulation of the AVM to
validate a transactions, solely from the code he can't predict the time the execution will finish. This will give an
adversary an opportunity to attack the network by broadcasting transactions that never ends. Since, validators can not
finish the execution of these transactions, the network will not be able to charge the attacker any fees, and he would
be able to waste validators resources for free.

To mitigate this problem, we require that every transaction specify a cap for all the resources it needs. This will
include memory, network and processor related resources. Also, the protocol defines an execution cost for every AVM
instruction reflecting the amount of resources it needs for emulation. This will define a standard way for measuring the
execution cost of any `avmCall` transaction. Every `avmCall` transaction is required to specify a maximum execution
cost. If during emulation it reaches this maximum cost, the transaction will be considered failed and the network can
receive the proposed fee of that transaction.

Every `avmCall` transaction is required to provide the following information as an upper bound for the resources it
needs:

- Execution cost
- A list of heap/code-area pages for reading
- A list of heap pages for writing
- A list of heap pages it will deallocate
- Number and size of heap pages it will allocate

If a transaction tries to violate any of these predefined limitations, for example, if it tries to read a memory
location that is not included in its reading list, it will be considered failed and the network can receive the proposed
fee of that transaction.

_A transaction always pays all of its proposed fee, no matter how much of its predefined resources were not used in the
final emulation._

#### ZK-EDB Servers

The incentive mechanism for ZK-EDB servers should have the following properties:

- It incentivizes storing all memory blocks, whether a heap page or a code area block, and not only those that are used
  more frequently.
- It incentivizes the ZK-EDB servers to actively provide the required memory blocks for validators.
- Making more accounts will not provide any advantages for a ZK-EDB server.

For our incentive mechanism, we require that every time a validator receives a memory block from a ZK-EDB, after
validating the data, he give a receipt to the ZK-EDB. In this receipt the validator signs the following information:

- `ownerAddr` the ALGO address of the ZK-EDB
- `receivedBlockID` the ID of the received memory block
- `round` the current round number

_In a round, an honest validator never gives a receipt for an identical memory block to two different ZK-EDBs._

To incentivize ZK-EDB servers, every round a lottery will be held and a predefined amount of ALGOs from `dbFeeSink`
account will be distributed between winners as a prize. This prize will be divided equally between all the *winning
tickets* of the lottery.

_One ZK-EDB server could own multiple winning tickets in a round._

To run this lottery, In every round, based on the current block seed, a collection of *valid* receipts will be selected
randomly as the *winning* receipts. A receipt is *valid* in the round `r` if:

- The signer was a validator in the round `r-1` and voted for the agreed-upon block
- The data block in the receipt was needed for validating the **previous** block
- The receipt round number is `r-1`
- The signer did not sign a receipt for the same data block for two different ZK-EDBs in the previous round

For selecting the winning receipts we could use a random generator:

```
if random(seed|validatorPK|receivedBlockID) < winProbability
    the receipt issued by validatorPK for receivedBlockID is a winner
```

- `random()` produces uniform random numbers between 0 and 1, using its input argument as a seed.
- `validatorPK` is the public key of the signer of the receipt.
- `receivedBlockID` is the ID of the memory block that the receipt was issued for.
- `winProbability` is the probability of winning in every round.
- `seed` is the current block seed.
- `|` is a concatenation operator.

_The winners of the lottery were validators one round before the lottery round._

Also, based on the current block seed, a random memory block, whether a heap page or a code area block, is selected as
the challenge of the round. A ZK-EDB that owns a winning receipt needs to broadcast a *winning ticket* to claim his
prize. The winning ticket consists of a winning receipt and a *solution* to the round challenge. Solving a round
challenge requires the content of the memory block which was selected as the round challenge. This will encourage
ZK-EDBs to store all memory blocks.

A possible choice for the challenge solution could be the cryptographic hash of the content of the challenge memory
block combined with the ZK-EDB ALGO address: `hash(challenge.content|ownerAddr)`

The winning tickets of the lottery of the round `r` need to be included in the block of the round `r`, otherwise they
will be considered expired. Validation and prize distribution for the winning tickets of the round `r` will be done in
the round `r+1`. This way, **the content of the challenge memory block could be kept secret during the lottery round.**
Every winning ticket will get an equal share of the lottery prize.

#### Memory Allocation and De-allocation

Every k round the protocol chooses a price per byte for the AVM memory. When a smart contract executes a heap allocation
instruction, the protocol will automatically deduce the cost of the allocated memory from the ALGO address of the smart
contract.

To determine the price of AVM memory, Every k round, the protocol calculates `dbFee` and `memTraffic` values. `dbFee` is
the aggregate amount of collected database fees and `memTraffic` is the total memory traffic of the system. For
calculating the memory traffic of the system the protocol considers the total size of all memory pages that were
accessed for either reading or writing during some time. These two values will be calculated for the last k rounds and
the price per byte of the AVM memory will be a linear function of `dbFee/memTraffic`

When a smart contract executes a heap de-allocation instruction, the protocol will refund the cost of de-allocated
memory to the smart contract. Here, the current price of AVM memory does not matter and the protocol calculates the
refunded amount based on the average price the smart had paid for that allocated memory. This will prevent smart
contracts from profit taking by trading memory with the protocol.

## Smart Contract Oracle

A smart contract oracle is a full AVM emulator that keeps a full local copy of AVM memory and can emulate AVM execution
without accessing a ZK-EDB. Smart contract oracles can be used for reporting useful information about `avmCall`
transactions such as accessed AVM heap pages or code area blocks, exact amount of execution cost, and so on.

<!---
h<sub>&theta;</sub>(x) = &pi;<sub>o</sub> x + &theta;<sub>1</sub>x
--->
