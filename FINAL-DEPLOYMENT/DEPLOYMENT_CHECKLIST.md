# 📋 DEPLOYMENT CHECKLIST

## **Pre-Deployment**
- [ ] Have your main NFT collection address ready
- [ ] Have your deployment wallet funded with gas
- [ ] Know your desired swap fees (e.g., 0.01 ETH)
- [ ] Know your desired fee split (e.g., 20% to central pool)

---

## **Phase 1: Core Infrastructure**

### ✅ Step 1: Deploy Central StonerFeePool
- [ ] Deploy `1_StonerFeePool.sol`
- [ ] Constructor: `(stonerNFT_address, receipt_address)`
- [ ] **Save address:** `CENTRAL_STONER_POOL = 0x...`

### ✅ Step 2: Deploy Factory
- [ ] Deploy `3_MultiPoolFactory.sol` 
- [ ] Constructor: `(CENTRAL_STONER_POOL)`
- [ ] **Save address:** `FACTORY = 0x...`

### ✅ Step 3: Register with Sonic FeeM
- [ ] Call `centralPool.registerMe()` 
- [ ] Verify registration successful

---

## **Phase 2: Per-Collection Pools**

**Repeat for each NFT collection:**

### ✅ Step 4: Deploy StakeReceipt
- [ ] Deploy `StakeReceipt.sol` (from root folder)
- [ ] Constructor: `("Collection Name Receipt", "SYMBOL")`
- [ ] **Save address:** `RECEIPT_[COLLECTION] = 0x...`

### ✅ Step 5: Deploy SwapPool  
- [ ] Deploy `2_SwapPool.sol`
- [ ] Constructor: 
  ```
  nftCollection:    0x... (NFT contract)
  receiptContract:  RECEIPT_[COLLECTION]
  stonerPool:       CENTRAL_STONER_POOL  
  swapFeeInWei:     10000000000000000 (0.01 ETH)
  stonerShare:      20 (20%)
  ```
- [ ] **Save address:** `SWAP_POOL_[COLLECTION] = 0x...`

### ✅ Step 6: Register Pool Pair
- [ ] Call `FACTORY.registerPoolPair(nftCollection, SWAP_POOL_[COLLECTION], RECEIPT_[COLLECTION])`
- [ ] Verify registration successful

---

## **Phase 3: Verification**

### ✅ Step 7: Test Core Functions
- [ ] Factory lists your pools: `factory.getAllPools()`
- [ ] Can find pool: `factory.getPoolInfo(nftCollection)`
- [ ] SwapPool shows correct settings
- [ ] Fee split working (test a small swap)

### ✅ Step 8: Frontend Integration
- [ ] Frontend can discover pools via factory
- [ ] Users can swap NFTs and pay fees
- [ ] Fees flow to central StonerFeePool
- [ ] Staking rewards work in central pool

---

## **🎯 Final Architecture**

```
Your Deployed System:

CENTRAL_STONER_POOL (receives all fees)
     ↑
FACTORY (tracks all pools)
     ↓
SWAP_POOL_A → NFT Collection A
SWAP_POOL_B → NFT Collection B  
SWAP_POOL_C → NFT Collection C
```

**Result:** Users stake in `CENTRAL_STONER_POOL` and earn from ALL swap activity! 🚀

---

## **📞 Contract Addresses (Fill in as you deploy)**

```
CENTRAL_STONER_POOL = 0x________________
FACTORY = 0x________________

Collection A:
  NFT_CONTRACT = 0x________________
  RECEIPT_TOKEN = 0x________________  
  SWAP_POOL = 0x________________

Collection B:
  NFT_CONTRACT = 0x________________
  RECEIPT_TOKEN = 0x________________
  SWAP_POOL = 0x________________
```