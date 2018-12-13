# Tron Pixel Contract Interfaces

## 1 Constants

```
uint32 constant public canvasWidth = 1000;  // width of the canvas
uint32 constant public canvasHeight = 1000;  // height of the canvas
uint32 constant public maxCoordinate = (canvasWidth * canvasHeight) - 1; // max number in this canvas
uint32 constant public activatePixelThreshold = 80000;  // threshold of pixels number for further action
uint constant public lastStageIncomeThreshold = 10000000000;  
uint32 constant public lastStageDuratio = 28800;
uint constant public defaultPrice = 20000000;  // default price of each pixels
uint8 constant public incrementRate = 35;  // increment of pixel price during each trading
uint8 constant public potRatio = 10;  // ratio to put in the pot when transaction happens
uint8 constant public referrerRatio = 5;  //  how many the referrer can get
uint8 constant public feeRatio = 25;  // transaction fee ratio
```

## 2 Public Data Members

```
uint8 public bonusRatio;  //  bouns ratio
uint8 public teamRatio;

uint8 public stage;
uint public endTime;  //  endtime of this stage
uint public lastStageIncome;  //  income of last stage
address public lastPainter;  // the address of last painter
uint public lastPaintedAt;  //  the coordinate drawn by the last painter
uint public bonusIndex;
uint32 public allPixelsPainted;  //  total number of drawn pixels
uint public grossIncome;  //  gross income
uint public teamBalance;
uint public marketValue;  //  the gross value of whole canvas
uint public finalPotAmount;
```

## 3 Payable methods

### 3.1 Buy pixels and set referrer address

// name: buyPixelsFristTime
// invoke when the user buy pixels for the very first time
| params   | type   | size | tip                        |
| ------ | ------ | ---- | ---------------------------- |
| pixelsToBuy | uint32 | --   | pixels' coordinate to buy |
| referrer | address | --  | referrer' s address          |
```solidity
function buyPixelsFristTime(uint32[] pixelsToBuy, address referrer) payable returns (uint32)
```

// name: buyPixels
// invoke when the user buy pixels
| params   | type   | size | tip                         |
| ------ | ------ | ---- | ---------------------------- |
| pixelsToBuy | uint32 | --   | pixels' coordinate to buy |
```solidity
function buyPixels(uint32[] pixelsToBuy) payable returns (uint32)
```

### 3.2 Buy pixels

## 4 Quering methods

### 4.1 Get total price of pixels

// name: getTotalPrice
// get total price of a given bunch of coordinates
| params   | type   | size | tip                         |
| ------ | ------ | ---- | ---------------------------- |
| coordinates | uint32(Array) | --   | pixels coordinate to query |
```solidity
function getTotalPrice(uint32[] coordinates) public view returns (uint totalPrice)
```

### 4.2 Get price of each pixels amount the array

// name: getPixelsPrice
// get each price of a given bunch of coordinates
| params   | type   | size | tip                         |
| ------ | ------ | ---- | ---------------------------- |
| coordinates | uint32(Array) | --   | pixels coordinate to query |
```solidity
function getPixelsPrice(uint32[] coordinates) public view returns (uint[])

// returns like
[
    0: t
    _hex: "0x01312d00"
    _ethersType: "BigNumber"
    __proto__: Object
    1: t
    _hex: "0x01312d00"
    _ethersType: "BigNumber"
    __proto__: Object
    2: t
    _hex: "0x01312d00"
    _ethersType: "BigNumber"
    __proto__: Object
    3: t
    _hex: "0x01312d00"
]
```

### 4.3 Get pixel information

// name: getPixel
// get the information by the given coordinate
| params   | type   | size | tip                        |
| ------ | ------ | ---- | ---------------------------- |
| coordinate | uint32 | --  | pixel coordinate to query |
```solidity
function getPixel(uint32 coordinate) public view returns (address owner, uint32 color, uint price)

// returns link
{
    color: 0
    owner: ""
    price: "20000000"
}
```

### 4.4 Get game information

// name: getGameInfo
// get the information of the game
```solidity
function getGameInfo() public view returns (uint, uint, uint, uint, uint32, uint, uint, address, uint, uint, uint, uint8, uint)

// returns like
{
    balance: "355796.311299"
    bonusIndex: "78.087283"
    currentHeight: 4902184
    endTime: "4925897"
    energyLimit: 0
    energyUsed: 0
    grossIncome: "153065.838271"
    lastPaintedAt: "4901623"
    lastPainter: "TWjrpbLtMdS27cnDmfYGygwq99J8zsiE2N"
    lastStageIncome: "7537.503885"
    marketValue: "195083.353569"
    pixels: 6953
    pixelsPainted: 8333
    potAmount: "15306.583827"
    stage: 0
    teamBalance: "52191.844848"
}
```

### 4.5 Get user information

// name: getUserInfo
// get the information of user
```solidity
function getPixel(uint32 coordinate) public view returns (address owner, uint32 color, uint price)
```

### 4.6 Get user information by address

// name: getUserInfoByAddress
// get the information of user by the given address
| params   | type   | size | tip                        |
| ------ | ------ | ---- | ---------------------------- |
| address | address | --  | address of user |
```solidity
function getUserInfoByAddress(address addr) public view returns (
    uint32 pixelsPaint, uint32 pixelsOwned, uint balance, uint bonusCollected,
    uint bonusUncollected, uint earning, address referrer, uint referrerAward)
```

### 4.7 Get paint logs


// name: getPaintLogs
// get the logs of recent user buying activity
| params   | type   | size | tip                        |
| ------ | ------ | ---- | ---------------------------- |
| offset | uint32 | --  | offset of this query |
| limit | uint32 | --  | limit of this query |
```solidity
function getPaintLogs(uint32 offset, uint32 limit) public view returns (address[], uint[], uint32[], uint32[])
```

## 5 Other methods

### 5.1 Player withdraw

// name: withdraw
// invoke the withdraw activity
```solidity
function withdraw() public
```

### 5.2 Team withdraw

// name: teamWithdraw
// invoke the teamWithdraw activity
```solidity
function teamWithdraw() public
```