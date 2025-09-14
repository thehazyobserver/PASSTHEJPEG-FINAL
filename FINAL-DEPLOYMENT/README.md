# 🚀 FINAL DEPLOYMENT CONTRACTS

## **Architecture Overview**

This is your **multi-pool non-proxy architecture** where:
- **One central StonerFeePool** receives fees from multiple SwapPools
- **Multiple SwapPools** for different NFT collections
- **Factory** tracks and manages all pools
- **No proxy complexity** - direct contract deployment

```
NFT Collection A → SwapPool A ┐
NFT Collection B → SwapPool B ┼─── Fees → Central StonerFeePool
NFT Collection C → SwapPool C ┘
```

---

## **📋 Deployment Order**

### **1. Central Infrastructure (Deploy Once)**

#### **1.1. Deploy Central StonerFeePool**
- **File:** `1_StonerFeePool.sol`
- **Constructor:**
  ```solidity
  constructor(address _stonerNFT, address _receiptToken)
  ```
- **Parameters:**
  - `_stonerNFT`: Your main NFT collection for staking
  - `_receiptToken`: A receipt token for the central pool

#### **1.2. Deploy Factory** 
- **File:** `3_MultiPoolFactory.sol`
- **Constructor:**
  ```solidity
  constructor(address _centralStonerFeePool)
  ```
- **Parameters:**
  - `_centralStonerFeePool`: Address from step 1.1

---

### **2. Per-NFT Collection (Repeat for Each Collection)**

#### **2.1. Deploy StakeReceipt**
- **File:** Use existing `StakeReceipt.sol` from root folder
- **Constructor:**
  ```solidity
  constructor(string memory name, string memory symbol)
  ```
- **Example:** 
  ```solidity
  StakeReceipt("Collection A Receipt", "CAR")
  ```

#### **2.2. Deploy SwapPool**
- **File:** `2_SwapPool.sol`
- **Constructor:**
  ```solidity
  constructor(
      address _nftCollection,      // NFT collection address
      address _receiptContract,    // StakeReceipt from step 2.1
      address _stonerPool,         // Central StonerFeePool from step 1.1
      uint256 _swapFeeInWei,       // e.g., 0.01 ether = 10000000000000000
      uint256 _stonerShare         // e.g., 20 = 20% to central pool
  )
  ```

#### **2.3. Register in Factory**
- **Call:** `factory.registerPoolPair(nftCollection, swapPool, stakeReceipt)`

---

## **🎯 Registry vs No Registry**

### **You NEED the Registry/Factory for:**
✅ **Frontend Integration** - Easy discovery of all pools
✅ **Analytics** - Track all pools from one place  
✅ **Batch Operations** - Manage multiple pools
✅ **Pool Discovery** - Find which pool exists for which collection
✅ **Centralized Management** - One interface for all pools

### **Registry provides:**
- `getPoolInfo(nftCollection)` - Find pool for collection
- `getAllPools()` - List all created pools
- `getActivePools()` - List only active pools
- Pool creation tracking and analytics

---

## **💡 Frontend Benefits**

The factory is **essential for your frontend** because it provides:

1. **Pool Discovery API:**
   ```solidity
   // Find pool for specific NFT collection
   (address swapPool, address stakeReceipt, bool exists) = factory.getPoolInfo(collectionAddress);
   
   // Get all available pools
   PoolData[] memory allPools = factory.getAllPools();
   ```

2. **Analytics Data:**
   ```solidity
   (uint256 totalPools, address centralPool, uint256 defaultFee, uint256 defaultShare) = factory.getFactoryStats();
   ```

3. **Batch Management:**
   - Track pool performance
   - Monitor fee distribution
   - Analytics dashboard data

---

## **📁 Files in This Folder**

| File | Purpose | Deploy Order |
|------|---------|-------------|
| `1_StonerFeePool.sol` | Central fee collector | 1st |
| `2_SwapPool.sol` | Individual swap pools | 3rd (per collection) |
| `3_MultiPoolFactory.sol` | Pool registry/factory | 2nd |
| `../StakeReceipt.sol` | Receipt tokens | Per collection |

---

## **🚀 Quick Start Deployment**

```solidity
// 1. Deploy central infrastructure
StonerFeePool centralPool = new StonerFeePool(stonerNFT, globalReceipt);
MultiPoolFactory factory = new MultiPoolFactory(address(centralPool));

// 2. For each NFT collection:
StakeReceipt receipt = new StakeReceipt("Collection Name Receipt", "CNR");
SwapPool pool = new SwapPool(
    nftCollection,           // NFT contract
    address(receipt),        // Receipt token
    address(centralPool),    // Central fee collector
    0.01 ether,             // Swap fee
    20                      // 20% to central pool
);

// 3. Register the pool pair
factory.registerPoolPair(nftCollection, address(pool), address(receipt));
```

---

## **✅ Benefits of This Architecture**

- 🎯 **Centralized Fees** - All swap fees go to one StonerFeePool
- 🔍 **Easy Discovery** - Frontend can find all pools via factory
- 📊 **Analytics** - Track all pools, fees, volume from one place
- ⚡ **Gas Efficient** - No proxy overhead
- 🛠️ **Scalable** - Easy to add new NFT collections
- 🔒 **Secure** - No upgrade complexity, immutable contracts

Your users stake in the **central StonerFeePool** and earn rewards from **all SwapPool activity** across all NFT collections! 🎉