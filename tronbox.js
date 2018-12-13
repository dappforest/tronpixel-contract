module.exports = {
  networks: {
    development: {
      from: 'THsLZSpz2uBvmurDMcjrpA34McJz6z4Dth',
      privateKey: '4DAA537031CA40F111DE869D22B6ED17DC107D9FCD07AAE63C0A625310829960',
      consume_user_resource_percent: 50,
      fee_limit: 100000000,
      host: "https://api.trongrid.io",
      port: 8090,
      fullNode: "https://api.shasta.trongrid.io",
      solidityNode: "https://api.shasta.trongrid.io",
      eventServer: "https://api.shasta.trongrid.io",
      network_id: "*" // Match any network id
    },
    production: {
      from: '',
      privateKey: '',
      consume_user_resource_percent: 30,
      fee_limit: 100000000,
      fullNode: "https://api.trongrid.io",
      solidityNode: "https://api.trongrid.io",
      eventServer: "it is optional",
      network_id: "*" // Match any network id
    }
  }
};
