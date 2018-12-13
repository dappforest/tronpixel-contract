pragma solidity ^0.4.16;

contract TronPixel {
  //============================================================================
  // Types
  //============================================================================
  struct User {
    uint32 pixelsPainted;
    uint32 pixelsOwned;
    uint balance;
    uint earning;
    uint referrerAward;
    uint bonusCollected;
    uint bonusMask;
    uint bonusSettled;
    address referrer;
  }

  struct Pixel {
    address owner;
    uint32 color;
    uint price;
  }
  
  struct PaintLog {
    address user;
    uint price;
    uint32 coordinate;
    uint32 color;
  }

  //============================================================================
  // Data members
  //============================================================================
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

//   uint32 constant public canvasWidth = 1000;
//   uint32 constant public canvasHeight = 1000;
//   uint32 constant public maxCoordinate = (canvasWidth * canvasHeight) - 1;
//   uint32 constant public activatePixelThreshold = 800;
//   uint constant public lastStageIncomeThreshold = 10000000000;
//   uint32 constant public lastStageDuratio = 200;
//   uint constant public defaultPrice = 20000000;
//   uint8 constant public incrementRate = 35;
//   uint8 constant public potRatio = 10;
//   uint8 constant public referrerRatio = 5;
//   uint8 constant public feeRatio = 25;
  
  uint8 public bonusRatio;
  uint8 public teamRatio;
  
  uint8 public stage;
  uint public endTime;
  uint public lastStageIncome;
  address public lastPainter;
  uint public lastPaintedAt;
  uint public bonusIndex;
  uint32 public allPixelsPainted;
  uint public grossIncome;
  uint public teamBalance;
  uint public marketValue;
  uint public finalPotAmount;
  
  mapping(address => User) users;
  mapping(uint32 => Pixel) pixels;
  PaintLog[] public logs;
  
  address admin;

  //============================================================================
  // Events
  //============================================================================
  // event PixelPaint(address user, uint price, uint32 coordinate, uint color);
  // event Withdrawal(address user, uint amount, uint bonus);

  //============================================================================
  // Constructor
  //============================================================================
  function TronPixel () {
    endTime = block.number + lastStageDuratio;
    admin = msg.sender;
    bonusRatio = 55;
    teamRatio = 100 - bonusRatio - potRatio;
  }

  //============================================================================
  // Helper function, utilities, and modifiers
  //============================================================================

  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }
  
  function updateOwnerInfo(address addr, uint _balance, uint _earning, uint _bonus) {
    var user = users[addr];
    user.balance += _balance;
    user.earning += _earning;
    user.bonusSettled += _bonus;
    user.pixelsOwned--;
  }
  
  function updateReferrerAward(address addr, uint amount) {
    var u = users[addr];
    u.balance += amount;
    u.referrerAward += amount;
  }

  //============================================================================
  // Transaction API
  //============================================================================

  // fallback function: use transfer memo as invoking params
  function () payable {
    // TODO: parse memo to pixels
  }

  function buyPixelsFristTime(uint32[] pixelsToBuy, address referrer) payable returns (uint32) {
    // require(users[referrer].pixelsPainted != 0);
    require(msg.sender != referrer);
    var u = users[msg.sender];
    // require(u.referrer == 0);
    if (users[referrer].pixelsPainted != 0 && u.referrer == 0) {
      u.referrer = referrer;
    }
    return buyPixels(pixelsToBuy);
  }

  function buyPixels(uint32[] pixelsToBuy) payable returns (uint32) {
    // require(pixelsToBuy.length % 2 == 0);
    uint totalSpent = 0;
    uint totalFees = 0;
    uint32 successCount = 0;
    var u = users[msg.sender];
    for (uint32 i = 0; i < pixelsToBuy.length - 1; i += 2) {
      uint32 coordinate = pixelsToBuy[i];
      require(coordinate <= maxCoordinate);
      uint32 color = pixelsToBuy[i+1];
      var p = pixels[coordinate];
      if (p.owner == 0) {
          // blank pixel, no owner
        if (msg.value < totalSpent + defaultPrice) {
            break;
        }
        totalSpent += defaultPrice;
        totalFees += defaultPrice;
        marketValue += defaultPrice;
        p.owner = msg.sender;
        p.color = color;
        p.price = defaultPrice;
        allPixelsPainted++;
        u.pixelsOwned++;
        logs.push(PaintLog(msg.sender, defaultPrice, coordinate, color));
      } else {
        // uint increment = SafeMath.div(SafeMath.mul(price, incrementRate), 100);
        uint increment = p.price * incrementRate / 100; 
        uint newPrice = p.price + increment;
        if (msg.value < totalSpent + newPrice) {
          break;
        }
        totalSpent += newPrice;
        totalFees += increment * feeRatio / 100;
        marketValue += increment;
        
        uint ownerEarning = increment * (100 - feeRatio) / 100;
        updateOwnerInfo(p.owner, p.price + ownerEarning, ownerEarning, bonusIndex);
        
        u.pixelsOwned++;
        p.color = color;
        p.price = newPrice;
        p.owner = msg.sender;
        logs.push(PaintLog(msg.sender, newPrice, coordinate, color));
      }
      successCount++;
    }
    require(successCount > 0);
    if (msg.value > totalSpent) {
      u.balance += (msg.value - totalSpent);
    }
    if (successCount > 0) {
      if (stage == 0) {
        if (block.number >= endTime) {
          // trigger pot
          finalPotAmount = grossIncome * potRatio / 100;
          users[lastPainter].balance += finalPotAmount;
          bonusRatio += potRatio;
          stage = 1;
        } else {
          lastStageIncome += totalFees;
          if (lastStageIncome >= lastStageIncomeThreshold) {
            endTime = block.number + lastStageDuratio;
            lastStageIncome = 0;
          }
          lastPaintedAt = block.number;
          lastPainter = msg.sender;
        }
      }
      grossIncome += totalFees;
      u.pixelsPainted += successCount;
      u.bonusMask += (bonusIndex * successCount);
      bonusIndex += (totalFees * bonusRatio / 100 / allPixelsPainted);
      if (u.referrer != 0) {
        updateReferrerAward(u.referrer, totalFees * referrerRatio / 100);
        teamBalance += (totalFees * (teamRatio - referrerRatio) / 100);
      } else {
        teamBalance += (totalFees * teamRatio / 100);
      }
    }
    return successCount;
  }
  
  function teamWithdraw() public {
    require(admin == msg.sender);
    require(teamBalance > 1000000);
    admin.transfer(teamBalance);
    teamBalance = 0;
  }

  function withdraw() public {
    require(allPixelsPainted > activatePixelThreshold);
    var u = users[msg.sender];
    uint bonusUncollected = bonusIndex * u.pixelsOwned - u.bonusMask - u.bonusCollected + u.bonusSettled;
    uint withdrawalAmount = u.balance + bonusUncollected;
    require(withdrawalAmount > 1000000);
    u.bonusCollected += bonusUncollected;
    u.balance = 0;
    msg.sender.transfer(withdrawalAmount);
  }

  //============================================================================
  // Querying API
  //============================================================================
  
  function getTotalPrice(uint32[] coordinates) public view returns (uint totalPrice) {
    for (uint32 i = 0; i < coordinates.length; i++) {
      uint32 coordinate = coordinates[i];
      var p = pixels[coordinate];
      if (p.owner == 0) {
        totalPrice += defaultPrice;
      } else {
        // uint increment = SafeMath.div(SafeMath.mul(price, incrementRate), 100);
        uint increment = p.price * incrementRate / 100; 
        totalPrice += (p.price + increment);
      }
    }
  }
  
  function getPixelsPrice(uint32[] coordinates) public view returns (uint[]) {
    uint[] memory prices = new uint[](coordinates.length);
    for (uint32 i = 0; i < coordinates.length; i++) {
      var p = pixels[coordinates[i]];
      if (p.owner == 0) {
        prices[i] = defaultPrice;
      } else {
        prices[i] = p.price + p.price * incrementRate / 100;
      }
    }
    return prices;
  }

  function getPixel(uint32 coordinate) public view returns (address owner, uint32 color, uint price) {
    var p = pixels[coordinate];
    if (p.owner == 0) {
      return (0, 0, defaultPrice);
    } else {
      return (p.owner, p.color, p.price + p.price * incrementRate / 100);
    }
  }
  
  function getGameInfo() public view returns (uint, uint, uint, uint, uint32, uint, uint, address, uint, uint, uint, uint8, uint) {
    uint potAmount = 0;
    if (stage == 0) {
      potAmount = grossIncome * potRatio / 100;
    } else {
      potAmount = finalPotAmount;
    }
    return (this.balance, marketValue, grossIncome, bonusIndex,
      allPixelsPainted, logs.length, lastPaintedAt, lastPainter, endTime,
      lastStageIncome, teamBalance, stage, potAmount);
  }
  
  function getUserInfo() public view returns (
      uint32 pixelsPaint, uint32 pixelsOwned, uint balance, uint bonusCollected,
      uint bonusUncollected, uint earning, address referrer, uint referrerAward) {
    return getUserInfoByAddress(msg.sender);
  }
  
  function getUserInfoByAddress(address addr) public view returns (
      uint32 pixelsPaint, uint32 pixelsOwned, uint balance, uint bonusCollected,
      uint bonusUncollected, uint earning, address referrer, uint referrerAward) {
    var u = users[addr];
    pixelsPaint = u.pixelsPainted;
    pixelsOwned = u.pixelsOwned;
    balance = u.balance;
    bonusCollected = u.bonusCollected;
    bonusUncollected = bonusIndex * u.pixelsOwned - u.bonusMask - u.bonusCollected + u.bonusSettled;
    earning = u.earning;
    referrer = u.referrer;
    referrerAward = u.referrerAward;
  }
  
  function getPaintLogs(uint32 offset, uint32 limit) public view returns (address[], uint[], uint32[], uint32[]) {
    uint len = logs.length;
    if (limit > 200 || offset >= len) return;
    uint rsize = limit;
    if (limit > len - offset) {
        rsize = len - offset;
    }
    address[] memory userAddrs = new address[](rsize);
    uint[] memory prices = new uint[](rsize);
    uint32[] memory coordinates = new uint32[](rsize);
    uint32[] memory colors = new uint32[](rsize);
    for (uint32 i = 0; i < rsize; i++) {
      userAddrs[i] = logs[i + offset].user;
      prices[i] = logs[i + offset].price;
      coordinates[i] = logs[i + offset].coordinate;
      colors[i] = logs[i + offset].color;
    }
    return (userAddrs, prices, coordinates, colors);
  }

  //============================================================================
  // Admin API
  //============================================================================

  //============================================================================
  // Library
  //============================================================================
}
