### Goals:

- The runtime environment for smart contracts should be free from any type of storage-memory impedance mismatch
  problem. A programmer will be able to write his smart contract without the need to think about the structure of
  permanent storage. He can simply assume his application will reside in main memory forever and he doesn't need
  storage.

- Smart contracts should be able to store considerable amount of data securely on blockchain. We achieve this by
  using zero knowledge data bases and using hybrid centralized-distributed methods for storing blockchain data, while
  the data servers need not be trusted entities.
  
- Nodes with limited computational resources (cpu/memory/storage) should be able to verify new blocks and
  participate in the consensus protocol. This will ensure the consensus protocol will always remain truly
  decentralized.
  
- Transaction validation should be done in parallel in different layers of the system to make sure we can benefit from
  both multicore architectures and node clustering techniques.
  

<!---
*α* =  − ln (1 − *M*<sub>*n* + *k*</sub>/*X*) / *n*
<img src="https://render.githubusercontent.com/render/math?math=e^{i \pi} = -1">
h<sub>&theta;</sub>(x) = &pi;<sub>o</sub> x + &theta;<sub>1</sub>x
--->
