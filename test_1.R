library("plyr")
library("dplyr")
library("httr")
library("xml2")
library("jsonlite")

# Possible bug: when sending SNK from a normal address to a stealth address,
# the sender's address balance might not be updated properly

## 0. Config:
url_api <- "sneak/url"
password <- "ferret"
amount_rewarded_first_time <- 180
amount_rewarded_second_time <- 43
change <- "" # for transferring funds
payed_amount <- 40

## 1. Create new wallet and save its IDs
created_wallet <- POST(paste0(url_api, "/actor/wallet/spawn"),
  body = paste0("{ \"password\": \"", password, "\"}"),
  content_type_json(),
  encode = "json") %>%
  content("parsed")

created_wallet_id <- created_wallet[["id"]]

## 2. Create new address associated to that wallet and save its ID
created_address <- POST(paste0(url_api, "/actor/wallet/address"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\"}"),
  content_type_json(),
  encode = "json") %>%
  content("parsed")
  
created_address_id <- ((as_list(created_address)[["html"]][["body"]][["p"]][[1]]) %>%
  fromJSON())[[1]]

## 3. Create new stealth address asociated to that wallet and save its ID:
created_stealth_address <- POST(paste0(url_api, "/actor/wallet/stealth/address"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\"}"),
  content_type_json(), encode = "json") %>%
  content("parsed")

created_stealth_address_id <- ((as_list(created_stealth_address)[["html"]][["body"]][["p"]][[1]]) %>%
    fromJSON())[[1]]

## 4. Reward the created (normal) address twice:
reward_1 <- POST(paste0(url_api, "/actor/wallet/reward"),
  body = paste0(
    "{ \"address\": \"", created_address_id, "\", ",
    "\"amount\": ", amount_rewarded_first_time, "}"),
  content_type_json(), encode = "json") %>%
  content("parsed")

reward_2 <- POST(paste0(url_api, "/actor/wallet/reward"),
  body = paste0(
    "{ \"address\": \"", created_address_id, "\", ",
    "\"amount\": ", amount_rewarded_second_time, "}"),
  content_type_json(), encode = "json") %>%
  content("parsed")

## 5. Check sender address' balance before transaction:
sender_balance_before_tx <- ((POST(paste0(url_api, "/actor/wallet/balance"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\", ",
    "\"address\": \"", created_address_id, "\"}"),
  content_type_json(), encode = "json") %>%
  content("parsed") %>%
  as_list())[["html"]][["body"]][["p"]][[1]] %>%
  fromJSON())[[1]]

## 6. Send transaction from normal to stealth address:
sent_tx <- POST(paste0(url_api, "/actor/wallet/transfer/funds"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\", ",
    "\"payer\": \"", created_address_id, "\", ",
    "\"payee\": \"", created_stealth_address_id, "\", ",
    "\"change\": \"", change, "\", ",
    "\"amount\": ", payed_amount, "}"),
  content_type_json(), encode = "json") %>%
  content("parsed")

## 7. Check sender's balance after transaction
sender_balance_after_tx <- ((POST(paste0(url_api, "/actor/wallet/balance"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\", ",
    "\"address\": \"", created_address_id, "\"}"),
  content_type_json(), encode = "json") %>%
    content("parsed") %>%
    as_list())[["html"]][["body"]][["p"]][[1]] %>%
    fromJSON())[[1]]

## 8. Check receiver's balance after transaction
receivers_balance_after_tx <- ((POST(paste0(url_api, "/actor/wallet/balance"),
  body = paste0(
    "{ \"identifier\": \"", created_wallet_id, "\", ",
    "\"password\": \"", password, "\", ",
    "\"address\": \"", created_stealth_address_id, "\"}"),
  content_type_json(), encode = "json") %>%
    content("parsed") %>%
    as_list())[["html"]][["body"]][["p"]][[1]] %>%
    fromJSON())[[1]]

# Results:
amount_rewarded_first_time
amount_rewarded_second_time
sender_balance_before_tx
payed_amount
sender_balance_after_tx
receivers_balance_after_tx




  






