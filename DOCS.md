# Creating Mock Contracts for Flow Blockchain

This guide explains how to create mock versions of mainnet contracts that work seamlessly across different networks (emulator, testnet, mainnet) using the same scripts and transactions.

## Overview

Mock contracts allow you to:

- Test your application logic without deploying to mainnet
- Avoid transaction fees during development
- Add testing-specific functionality (like public minting)
- Maintain the same interface as the production contract

## Key Rules for Network-Compatible Mock Contracts

### 1. **Identical Contract Name**

Your mock contract **must** use the exact same name as the mainnet contract.

```cadence
// ❌ Wrong - Different contract name
access(all) contract USDF_MOCK: FungibleToken {

// ✅ Correct - Same name as mainnet
access(all) contract EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed: FungibleToken {
```

### 2. **Identical Storage Paths**

Use the **exact same** storage and public paths as the mainnet contract.

```cadence
// In init(), use the same paths as mainnet
self.VaultStoragePath = /storage/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
self.VaultPublicPath = /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault  
self.ReceiverPublicPath = /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedReceiver
```

### 3. **Compatible Public Interface**

Implement the same public functions and resources as the mainnet contract, or provide compatible alternatives.

```cadence
// Ensure your mock has the same public interface
access(all) resource Vault: FungibleToken.Vault {
    // Same methods as mainnet contract
    access(all) var balance: UFix64
    access(all) fun deposit(from: @{FungibleToken.Vault})
    access(FungibleToken.Withdraw) fun withdraw(amount: UFix64): @{FungibleToken.Vault}
    // ... other required methods
}
```

### 4. **Network Aliases in flow.json**

Configure your `flow.json` to use network aliases that point to different addresses:

```json
{
  "contracts": {
    "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed": {
      "source": "cadence/contracts/USDF_MOCK.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "testnet": "0x...",
        "mainnet": "1e4aa0b87d10b141"
      }
    }
  }
}
```

### 5. **Hard-coded Paths in Scripts/Transactions**

Since mainnet contracts may not expose path constants publicly, use hard-coded paths in your scripts and transactions:

```cadence
// ✅ Use hard-coded paths that work on all networks
if let vaultRef = accountRef.capabilities.borrow<&ContractName.Vault>(
    /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
) {
    return vaultRef.balance
}
```

## Step-by-Step Implementation Guide

### Step 1: Research the Mainnet Contract

1. Find the contract address and name on Flow blockchain explorers
2. Examine the contract's public interface using scripts
3. Identify the storage paths used by the contract
4. Note the token metadata (name, symbol, decimals)

### Step 2: Create Your Mock Contract

1. **Name your contract** exactly the same as mainnet
2. **Implement the same interfaces** (e.g., `FungibleToken` for tokens)
3. **Use identical storage paths** from the mainnet contract
4. **Add testing conveniences** like public minting functions
5. **Maintain interface compatibility** for all public methods

### Step 3: Configure flow.json

1. **Add your contract** with the mainnet name
2. **Set up network aliases** pointing to appropriate addresses
3. **Include necessary dependencies** (FungibleToken, MetadataViews, etc.)
4. **Remove unused dependencies** to keep the configuration clean

### Step 4: Write Universal Scripts/Transactions

1. **Import the contract** using its mainnet name
2. **Use hard-coded storage paths** instead of contract constants
3. **Handle network differences** gracefully (e.g., different metadata access methods)
4. **Test on both networks** to ensure compatibility

## Example Implementation

Here's how we implemented a USDF mock contract:

### Contract Structure

```cadence
access(all) contract EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed: FungibleToken {
    // Same storage paths as mainnet
    access(all) let VaultStoragePath: StoragePath
    access(all) let VaultPublicPath: PublicPath
    access(all) let ReceiverPublicPath: PublicPath
    
    // Mock-specific: Public mint function for testing
    access(all) fun mintTokens(amount: UFix64): @{FungibleToken.Vault} {
        // Testing convenience not available on mainnet
    }
    
    init() {
        // Use identical paths to mainnet
        self.VaultStoragePath = /storage/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
        self.VaultPublicPath = /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
        self.ReceiverPublicPath = /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedReceiver
    }
}
```

### Universal Script Example

```cadence
import "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed"

access(all) fun main(account: Address): UFix64 {
    let accountRef = getAccount(account)
    
    // Hard-coded path works on all networks
    if let vaultRef = accountRef.capabilities.borrow<&EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.Vault>(
        /public/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
    ) {
        return vaultRef.balance
    }
    return 0.0
}
```

### flow.json Configuration

```json
{
  "contracts": {
    "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed": {
      "source": "cadence/contracts/USDF_MOCK.cdc",
      "aliases": {
        "emulator": "f8d6e0586b0a20c7",
        "mainnet": "1e4aa0b87d10b141"
      }
    }
  },
  "deployments": {
    "emulator": {
      "emulator-account": ["EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed"]
    }
  }
}
```

## Testing Your Implementation

### Test on Emulator

```bash
# Deploy your mock contract
flow project deploy --network emulator

# Test scripts and transactions
flow scripts execute path/to/script.cdc --network emulator
flow transactions send path/to/transaction.cdc --network emulator --signer account
```

### Test on Mainnet

```bash
# Test scripts (read-only, no deployment needed)
flow scripts execute path/to/script.cdc --network mainnet

# Transactions will use the real mainnet contract
flow transactions send path/to/transaction.cdc --network mainnet --signer account
```

## Common Pitfalls to Avoid

### ❌ Don't Use Different Contract Names

```cadence
// This won't work with network aliases
access(all) contract MyTokenMock: FungibleToken {
```

### ❌ Don't Use Contract Constants for Paths in Scripts

```cadence
// This may fail on mainnet if the contract doesn't expose these constants
if let vault = account.borrow<&Vault>(MyContract.VaultStoragePath) {
```

### ❌ Don't Assume All Methods Exist

```cadence
// Mainnet contract might not have this method
let decimals = MyContract.getDecimals() // May fail on mainnet
```

### ✅ Do Use Hard-coded Compatible Paths

```cadence
// This works on all networks
if let vault = account.borrow<&Vault>(/storage/MyContractVault) {
```

### ✅ Do Handle Network Differences Gracefully

```cadence
// Fallback to metadata views if direct methods don't exist
let ftView = MyContract.resolveContractView(/* ... */) as! FungibleTokenMetadataViews.FTDisplay?
let decimals = ftView?.decimals ?? 6 // Fallback value
```

## Benefits of This Approach

1. **Single Codebase**: One set of scripts/transactions for all networks
2. **Easy Testing**: Mock contracts can have testing conveniences like public minting
3. **Production Ready**: Same scripts work seamlessly on mainnet
4. **Cost Effective**: No transaction fees during development on emulator
5. **Realistic Testing**: Mock maintains same interface and behavior as production

## Conclusion

By following these rules and patterns, you can create mock contracts that provide a seamless development experience across different Flow networks. The key is maintaining interface compatibility while leveraging Flow's network alias system to automatically point to the right contract on each network.