# 🔸 NFT Vault System – From Scratch, Fully Covered

![Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Foundry](https://img.shields.io/badge/Built%20with-Foundry-%237212dd)

A complete, modular NFT system consisting of:

- 🤩 `MyNFT` – a minimal, ERC721-compatible NFT contract  
- 🛡️ `NFTHolder` – a vault contract that securely **receives and stores NFTs** using `onERC721Received`

Everything is written **from scratch** without OpenZeppelin or external dependencies — designed with **security, readability, and testing** in mind.  
Achieves **100% code coverage** using **Foundry** with unit tests for every logic path, revert, and edge case.

---

## ✨ Features

### 🔹 `MyNFT.sol`
- ERC721-style functionality (mint, transfer, approvals, metadata)
- Gas-optimized custom errors
- Secure permission checks on all token operations
- Dynamic `tokenURI` construction
- Built-in `safeTransferFrom` with `ERC721Receiver` compatibility

### 🔸 `NFTHolder.sol`
- Receives ERC721 tokens via `onERC721Received`
- Tracks original depositor ownership of each NFT
- Allows withdrawals only by original depositor
- Emits clear `NFTDeposited` and `NFTWithdrawn` events
- Enforces address validity with custom reverts

---

## 🧠 Architecture

```
[User] --mint--> [MyNFT] --safeTransferFrom()--> [NFTHolder]
                            ↳ onERC721Received()
[User] <--withdrawNFT()-- [NFTHolder] --safeTransferTo--> [MyNFT]
```

---

## 🧪 Testing & Coverage

Every function and branch in both contracts is fully tested using [Foundry](https://book.getfoundry.sh/) and validated with `forge coverage`.

### ✅ Covered Test Cases:
| Contract     | Feature                                  | Test Status |
|--------------|-------------------------------------------|-------------|
| `MyNFT`      | Minting, double mint prevention           | ✅           |
|              | Transfers (`transferFrom`, `safeTransferFrom`) | ✅     |
|              | Approvals & operator logic                | ✅           |
|              | Reverts: unauthorized transfers, invalid IDs | ✅       |
|              | Metadata URI logic                        | ✅           |
| `NFTHolder`  | ERC721 receiver hook                      | ✅           |
|              | Owner-only withdrawal                     | ✅           |
|              | Reverts: invalid address / not owner      | ✅           |
|              | Event emissions                           | ✅           |

### 🔧 Run tests

```bash
forge test -vv
```

### 📊 Run coverage

```bash
forge coverage
```

---

## 📆 Project Structure

```
.
├── src/
│   ├── MyNFT.sol              # Minimal ERC721
│   ├── NFTHolder.sol          # NFT Vault contract
│   └── Interfaces.sol         # IERC721 + IERC721Receiver
│
├── test/
│   ├── MyNFT.t.sol            # MyNFT full test suite
│   ├── NFTHolder.t.sol        # NFTHolder full test suite
│
└── foundry.toml
```

---

## 🛠️ Tech Stack

- **Language**: Solidity `^0.8.24`
- **Testing**: [Foundry](https://book.getfoundry.sh/)
- **Coverage**: 100% with `forge coverage`
- **No OpenZeppelin or third-party contracts used**

---

## 📓 Example Usage

### Mint and Deposit

```solidity
myNFT.mint(1); // Mint tokenId 1
myNFT.safeTransferFrom(msg.sender, address(nftHolder), 1);
```

### Withdraw

```solidity
nftHolder.withdrawNFT(address(myNFT), 1); // Only original depositor can call this
```

---

## 📜 License

MIT © 2024

---

## 👨‍💻 Author

Built with 💙 by [Muzammil](https://github.com/Eunum56)  
> Solidity Developer · DeFi Builder · Smart Contract Security Learner
