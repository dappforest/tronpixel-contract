# Tron Pixel Contract Interfaces

## 1 Constants

```
uint32 constant public canvasWidth = 1000;
uint32 constant public canvasHeight = 1000;
uint32 constant public maxCoordinate = (canvasWidth * canvasHeight) - 1;
uint32 constant public activatePixelThreshold = 80000;
uint constant public lastStageIncomeThreshold = 10000000000;
uint32 constant public lastStageDuratio = 28800;
uint constant public defaultPrice = 20000000;
uint8 constant public incrementRate = 35;
uint8 constant public potRatio = 10;
uint8 constant public referrerRatio = 5;
uint8 constant public feeRatio = 25;
```

## 2 Public Data Members



## 3 Payable methods

### 3.1 Buy pixels and set referrer address

```
function buyPixelsFristTime(uint32[] pixelsToBuy, address referrer) payable returns (uint32)
```

### 3.2 Buy pixels

## 4 Quering methods

### 4.1 Get total price of pixels

### 4.2 Get each price of the pixels

### 4.3 Get pixel information

### 4.4 Get game information

### 4.5 Get user information

### 4.6 Get user information by address

### 4.7 Get paint logs

## 5 Other methods

### 5.1 Player withdraw

### 5.2 Team withdraw