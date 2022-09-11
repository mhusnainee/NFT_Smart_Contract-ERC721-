# NFT_Smart_Contract_ERC721

## Opensea NFTs Collection Link :

``` https://testnets.opensea.io/Marvel_Cinematic-Universe ```

## Wallet Address :

``` 0xb83384A28DA9aB123dD397BC3C08CD8cC94a12EB ```

## Contract Deployed on: Rinkeby Testnet

## Contract Address :

``` 0xDc9e0A24402287A48648524710B637F9De5F3473 ```

### Contract Requirements

ERC-721 Compliance Compatible

### Users will be

Whitelisted users

Public users

### NFT  Minting Limit

Total Minting Limit

Whitelisted users Minting Limit

Public users Minting Limit

Platform Minting (admin) Limit
            
- Whitelist User Minting:

Only whitelist users are allowed to mint the NFTs.

If the Whitelist User's Minting limit is reached then whitelist users cannot mint the NFTs.

- Public Minting:

Public Minting is only available when public sales are active.

If the public minting limit is reached then public cannot mint the NFTs.

- Platform Minting:

Platform minting is for platfrom admins only.

If the platform limit is reached admins cannot mint NFTs.

## What we need as deliveries:

NFTs will be reserved with respect to limit i.e. 1 address can mint up to 5 NFTs.

Contract will also have whitelisted admins that can be added or removed by the owner of the contract only.

Default Base URI will be set or updated by whitelisted admins only.

Contract will have a pause/un-pause minting feature. Minting status can be changed by the owner of the contract.

Token Ids will not be managed within the contract. It will be passed as a parameter in the minting function.

Contract stores the following attributes of NFTs:

- ID
- Name
- Metadata hash

Whitelisted addresses can mint as public users. We’ll define a limit for each user that will include whitelisted and public minting.

Whitelisted admins cannot mint NFTs if the minting status is paused.

Public users cannot mint NFTs if public sales are not active.

We have reserved a limit for each Admin, Whitelisted user, and public.

(This functionality is not yet implemented in the contract but will be in the future) Let's say we have a total minting limit is 100. In which we reserved 10 for admins and 50 for whitelisted users. The remaining limit is 40. So 40 limit will be reserved for public sales. If whitelisted users only mint 40 NFTs out of 50 remaining 10 NFTs will be added to the public limit if the public sale is still active.
Furthermore, when you activate the public sale then whitelist users cannot mint the NFTs.
