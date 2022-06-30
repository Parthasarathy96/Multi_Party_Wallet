const dotenv = require('dotenv');
dotenv.config();

module.exports = {
  solidity: "0.8.0",
  defaultNetwork: "rinkeby",
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/Btr94MtiAJQl0xhB6ktaQ_S75TG1ENy1",
      accounts: [process.env.PRIVATEKEY]
    }
  }
};
