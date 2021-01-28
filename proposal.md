## Introduction
The Algorand Virtual Machine (AVM) is an abstract computing machine for executing Algorand's smart contracts. It is designed in a way that it could be efficiently implemented in either hardware or software.

## The Structure of the Algorand Virtual Machine
...

### Data Types
The Algorand Virtual Machine expects that all type checking is done prior to run time, typically by a compiler, and does not have to be done by the Algorand Virtual Machine itself.

The instruction set of the Algorand Virtual Machine distinguishes its operand types using instructions intended to operate on values of specific types. For instance, `iadd` assumes that its operands are two 64 bit integers.

### The `PC` Register
...
### The `fuelTank` Register
Before executing an instruction the Algorand virtual machine subtracts the predefined cost of that instruction from the `fuelTank` register. A negative value in this register will cause the AVM to throw an exception. AVM has no instruction for directly manipulating the `fuelTank` register.

### Call Stack
A call stack contains the information that is needed for restoring the state of the invoker of a method.

### Memory Unit
The Algorand Virtual Machine has a byte addressable memory which is divided into separate segments. Every segment belongs to a smart contract that has a unique `applicationID`. AVM always has a single working memory segment and memory locations outside of its current working segment can not be accessed. The only instructions that can change the current working segment are `invoke_external`, `athrow` and return instructions. 

Every smart contract has its own memory segment. Hence, there is no way for a smart contract to access another smart contract's memory. Interaction between smart contracts is done by using `invoke_external` instruction. A smart contract can invoke methods of another smart contract by using this instruction.

A memory segment consists of five data areas:

- Code Area
- Constant Area
- Local Frame
- Operand Stack
- Heap

All these areas are separately addressable and their starting address is 0. Every memory access instruction operates on its specific data areas.

#### Code Area
The code area of a segment contains the byte-code of the smart contract that owns that segment. AVM has no instruction for manipulating the code area. **Installing, removing and updating smart contracts' byte-code need to be done externally.**

#### Constant Area
The constant area of a segment contains several kinds of constants, ranging from user defined constants to method address tables. A method address table stores method locations in the code area and their access type. A method's access type can be either `public` or `private`. AVM has no instructions for modifying the constant area.

#### Local Frame
A local frame is used to store methods' parameters and local variables. A new frame is created each time a method is invoked. A frame is destroyed when its method invocation completes, whether that completion is normal or abrupt.

#### Operand Stack
Every time a local frame is created, a corresponding empty last-in-first-out (LIFO) stack is created. AVM instructions take operands from the operand stack, operate on them, and push the result back onto the operand stack. An operand stack is destroyed when its owner method completes, whether that completion is normal or abrupt.

#### Heap
The heap of a segment is a persistent memory area which is divided into pages. Each page can be referenced by an index that starts from 0 and the memory locations inside every page have a separate address space that start from 0. In other words, the address of every memory location inside a heap is a pair of indices: `(pageIndex, offset)`. Pages of a heap need not to be equally sized. 

_the reason behind this paged design is that the heap is usually persisted using a block device. A heap with a paged structure could expose the underlying block based nature of persistence layer to the application. In this way, the compiler or the programmer could better optimize the code for the persistence layer._

## Instruction Set Summary
An Algorand Virtual Machine instruction consists of a **one-byte** opcode specifying the operation to be performed, followed by zero or more operands supplying arguments or data that are used by the operation. The number and size of the operands are determined solely by the opcode.

### Method Invocation
The Algorand Virtual Machine has three type of method invocation:

- `invoke_internal` invokes a method from the current running smart contract.
- `invoke_external` invokes a `public` method from another smart contract. it will change the current memory segment to that smart contract's segment.
- `invoke_native` invokes a method that is not hosted by the Algorand virtual machine. By this instruction, high performance native methods of a hosting machine could become available to AVM smart contracts.

_in the future, we may need to add special instructions for invoking interface and virtual methods..._

Each time a method is invoked a new local frame and operand stack is created. The Algorand Virtual Machine uses [local frames](#local-frame) to pass parameters on method invocation. On method invocation, any parameters are passed in consecutive local variables stored in the method's local frame starting from local variable 0. The invoker of a method writes the parameters inside the method's local frame using `arg` instructions.


### Exceptions
An exception is thrown programmatically using the `athrow` instruction. Exceptions can also be thrown by various Algorand Virtual Machine instructions if they detect an abnormal condition. 

### Method Invocation Completion
A method invocation completes normally if that invocation does not cause an exception to be thrown, either directly from the AVM or as a result of executing an explicit throw statement. If the invocation of the current method completes normally, then a value may be returned to the invoking method. This occurs when the invoked method executes one of the return instructions, the choice of which must be appropriate for the type of the value being returned (if any). Execution then continues normally in the invoking method's local frame with the returned value (if any) pushed onto the operand stack.  

A method invocation completes abruptly if an exceptions is thrown and is not caught by the current method. A method invocation that completes abruptly never returns a value to its invoker. 

When a method completes, whether normally or abruptly, the call stack is used to restore the state of the invoker, including its local frame and operand stack, with the `PC` register appropriately restored and incremented to skip past the method invocation instruction. If the invoker was another smart contract, i.e. the invocation was made by an `invoke_external` instruction, the current memory segment will be changed to the invoker's segment. 

A thrown exception causes methods in the call stack to complete **abruptly** one by one, as long as the next instruction is not a `catch` instruction. The `catch` instruction acts like a branch instruction that branches only if an exception is caught.  **When an external method invocation completes abruptly, before changing the current segment, all changes made to the heap area will be rolled back.**

_By using this feature and `athrow` instruction, a programmer can make any method act like an atomic operation._

### Heap Allocation Instructions
...

## Implementation
### Persistence
For implementing the persistence layer of the AVM, we assume that we have access to an updatable ZK-EDB with the following properties:

- ZK-EDB is a mapping from a set of keys to values. 
- Every state of the database has a commitment C. 
- ZK-EDB has a method (D, p) = DB.get(x), where x is a key and D is the associated value with x and p is a proof.
- A user can use C and p to verify that D is really associated with x and D in not altered. Hence, a user who can obtain C from a trusted source do not need to trust the ZK-EDB.
- Having p and C a user can compute the commitment C' for the database that in it D' is associated with x instead of D. 

We use a ZK-EDB for storing the AVM heap. We include the commitment of the current state of this DB in every block of the Algorand blockchain so the ZK-EDB servers need not to be trusted servers.

Every page of AVM heap will be stored with a key of the form: `applicationID|pageIndex` (the | is concatenation operator). Nodes do not keep a full copy of AVM heap and for validating block certificates or emulating AVM (i.e. validating transactions) they need to connect to some ZK-EDB and retrieve the required pages of AVM heap. For better performance, nodes keep a cache of heap pages to reduce the amount of ZK-EDB access.

We also use a ZK-EDB for storing the code area of each segment and we include the commitment of this DB in every block. Every code area will be stored in the DB with `applicationID` as its key. Like heap pages, nodes also keep a cache of code areas.

### Blockchain
Every block of Algorand blockchain corresponds to a set of transactions. We store the hash of this set in every block but we don't keep the transaction set itself. To be able to detect replay attacks, we require every signature that a user creates to have a nonce. This nonce consists of the issuance round of a signature and a sequence number: `(issuance, sequence)`. When a user creates more than one signature in a round, he needs to sequence his signatures starting from 0. We define a maximum life time for signatures, so a signature is invalid if `currentRound - issuance > maxLifeTime` or if a signature of the same user with a bigger or equal nonce is already used (i.e. is recorded in the blockchain). A nonce is bigger than another nonce if it has an older issuance. If two nonces have an equal issuance the nonce with the bigger sequence number will be considered to be bigger.

To be able to detect invalid signatures, we keep the maximum nonce of used digital signatures per user. When the difference between `issuance` component of this nonce and the current round becomes bigger than the maximum allowed life time of a signature, this information can be safely deleted. **In this way, we will not have the problem of "unremovable empty accounts" like Ethereum.**

The only information that Algorand's nodes are required to store is the Algorand blockchain. Every block of the Algorand blockchain contains the following information: 

| Block |
| ---- |
| commitment to the ZK-EDB storing heap pages |
| commitment to the ZK-EDB storing code areas |
| hash of transactions |
| certificate of the previous block |

For confirming a new block, nodes that are not validators only need to verify the block certificate. For verifying a block certificate, a node needs to know the ALGO balances of validators, but it doesn't need to emulate the AVM execution. On the other hand, nodes that are chosen to be validators, need to emulate execution of the Algorand virtual machine and calculate and confirm the new ZK-EDB commitments. They also need to calculate the hash of new block's transactions.

### Transactions

Transferring all assets including ALGOs is done by AVM smart contracts. For Interacting with an AVM smart contract a user broadcasts an `AvmCall` transaction. an `AvmCall` transaction essentially is two `invoke_external` instructions. The first `invoke_external` is always a method invocation from Algorand's main smart contract which buys `fuel` by sending ALGOs to the fee sink account. The second `invoke_external` invokes the requested method.

Every `AvmCall` transaction is required to exactly specify what heap pages it will access. This will enable validators to start retrieving required heap pages from available ZK-EDB servers as soon as they see a transaction and they don't need to wait for receiving the new proposed block. A transaction that tries to access a page that is not included in its `pageAccessList` field, will be rejected. Users could use smart contract oracles to find the list of heap pages that their transactions need.

## Smart Contract Oracle
A smart contract oracle is a full AVM emulator that keeps a full local copy of AVM memory and can emulate AVM execution without accessing a ZK-EDB. Smart contract oracles can be used for reporting useful information about `AvmCall` transactions such as accessed AVM heap pages, exact amount of fuel used, etc.


<!---
h<sub>&theta;</sub>(x) = &pi;<sub>o</sub> x + &theta;<sub>1</sub>x
--->
