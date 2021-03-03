Introduction
============

The Algorand Virtual Machine (AVM) is an abstract computing machine for executing Algorand’s smart contracts. It is
designed in a way that it could be efficiently implemented in either hardware or software.

The Structure of the Algorand Virtual Machine
=============================================

...

Data Types
----------

The Algorand Virtual Machine expects that all type checking is done prior to run time, typically by a compiler, and does
not have to be done by the Algorand Virtual Machine itself.

The instruction set of the Algorand Virtual Machine distinguishes its operand types using instructions intended to
operate on values of specific types. For instance, `iadd` assumes that its operands are two 64-bit integers.

The `PC` Register
-----------------

...

Call Stack
----------

A call stack contains the information that is needed for restoring the state of the invoker of a method.

Memory Unit
-----------

The Algorand Virtual Machine has a byte addressable memory which is divided into separate segments. Every segment
belongs to a smart contract that has a unique `applicationID`. The AVM always has a single working memory segment and
memory locations outside its current working segment can not be accessed. The only instructions which can change the
current working segment are `invoke_external`, `athrow` and return instructions.

Every smart contract has its own memory segment. Hence, there is no way for a smart contract to access another smart
contract’s memory. Interaction between smart contracts is done using `invoke_external` instruction, and A smart contract
can invoke methods of another smart contract by this instruction.

A memory segment consists of five data areas:

-   Code Area

-   Constant Area

-   Local Frame

-   Operand Stack

-   Heap

All data areas except operand stack, have their own address space which starts from 0. Operand stack is a
last-in-first-out (LIFO) stack and is not addressable. Every memory access instruction operates on its specific data
areas.

### Code Area

The code area of a segment contains the byte-code of the smart contract which owns that segment. The AVM has no
instructions for manipulating the code area. **Installing, removing and updating smart contracts need to be done
externally.**

### Constant Area

The constant area of a segment contains several kinds of constants, ranging from user defined constants to method
address tables. A method address table stores method locations in the code area and their access type. The access type
of a method can be either `public` or `private`. The AVM has no instructions for modifying the constant area.

*Only public methods can be invoked by `invoke_external` instruction.*

### Local Frame

A local frame is used to store methods parameters and local variables. A new frame is created each time a method is
invoked. A frame is destroyed when its method invocation completes, whether the completion is normal or abrupt.

### Operand Stack

Every time a local frame is created, a corresponding empty last-in-first-out (LIFO) stack is created too. AVM
instructions take operands from the operand stack, operate on them, and push the result back onto the operand stack. An
operand stack is destroyed when its owner method completes, whether that completion is normal or abrupt.

### Heap

The heap of a segment is a persistent memory area which is divided into pages. Each page can be referenced by an index
that starts from 0. Memory locations inside every page have a separate address space that starts from 0. In other words,
the address of every memory location inside a heap is a pair of indices: `(pageIndex, offset) `. Pages of a heap do not
need to be equally sized.

*The reason behind this paged design is that the heap is usually persisted using a block device. A heap with a paged
structure could expose the underlying block based nature of the persistence layer to the application layer. In this way,
the compiler or the programmer could better optimize the code for the persistence layer.*

Instruction Set Summary
=======================

An Algorand Virtual Machine instruction consists of a **one-byte** opcode specifying the operation to be performed,
followed by zero or more operands supplying arguments or data that are used by the operation. **The number and size of
the operands are determined solely by the opcode.**

Method Invocation
-----------------

The Algorand Virtual Machine has three types of method invocation:

-   `invoke_internal` invokes a method from the current running smart contract.

-   `invoke_external` invokes a `public` method from another smart contract. It will change the current memory segment
    to the segment of the invoked smart contract.

-   `invoke_native` invokes a method that is not hosted by the Algorand virtual machine. By this instruction, high
    performance native methods of a hosting machine could become available to AVM smart contracts.

*In the future, we may need to add special instructions for invoking interface and virtual methods...*

Each time a method is invoked a new local frame and operand stack is created. The Algorand Virtual Machine uses local
frames to pass parameters on method invocation. On method invocation, any parameters are passed in consecutive local
variables stored in the method’s local frame starting from local variable 0. The invoker of a method writes the
parameters in the local frame of the invoked method using `arg` instructions.

### Exceptions

An exception is thrown programmatically using the `athrow` instruction. Exceptions can also be thrown by various
Algorand Virtual Machine instructions if they detect an abnormal condition. Some exceptions are not catchable and will
always abort the execution of the smart contract.

### Method Invocation Completion

A method invocation completes normally if that invocation does not cause an exception to be thrown, either directly from
the AVM or as a result of executing an explicit throw statement. If the invocation of the current method completes
normally, then a value may be returned to the invoking method. This occurs when the invoked method executes one of the
return instructions, the choice of which must be appropriate for the type of the value being returned (if any).
Execution then continues normally in the invoking method’s local frame with the returned value (if any) pushed onto the
operand stack.

A method invocation completes abruptly if an exceptions is thrown and is not caught by the current method. A method
invocation that completes abruptly never returns a value to its invoker.

When a method completes, whether normally or abruptly, the call stack is used to restore the state of the invoker,
including its local frame and operand stack, with the `PC` register appropriately restored and incremented to skip past
the method invocation instruction. If the invoker was another smart contract, i.e. the invocation was made by an
`invoke_external` instruction, the current memory segment will be changed to the invoker’s segment.

A thrown exception causes methods in the call stack to complete **abruptly** one by one, as long as the `PC` register is
not pointing to a `catch` instruction. The `catch` instruction acts like a branch instruction that branches only if an
exception is caught. **When an external method invocation completes abruptly, before changing the current segment, all
changes made to the heap area will be rolled back.**

*By using the `athrow` instruction properly, a programmer can make any method act like an atomic operation.*

### Authorizing Operations

In blockchain applications, we usually need to authorize certain operations. For example, for sending an asset from a
user to another user, first we need to make sure that the sender has authorized this operation. The Algorand virtual
machine has no built in mechanism for authorizing operations, but it provides a rich set of cryptographic instructions
for validating signatures and cryptographic entities. By using these instructions and passing signatures as parameters
to methods a programmer can implement the required logic for authorizing any operation.

*The Algorand virtual machine has no instructions for issuing cryptographic signatures.*

In addition to signatures, a method can verify its invoker by using `get_parent` instruction. This instruction gets the
`applicationID` of the smart contract that is one level deeper than the current smart contract in the call stack. In
other words, it gives the smart contract that has invoked the current smart contract. (if any)

### Heap Allocation Instructions

...