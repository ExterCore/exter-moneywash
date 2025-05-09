
# 🧺 exter-moneywash

An interactive and modular money laundering script for QBCore, inspired by modern money laundering systems like in NoPixel. Players can build their own equipment like baskets, dryers, and fans to organize the illegal money laundering process with machine cooling & heating challenges.

This script is standalone. You can run this script on any framework.

You can use the /props command to open the placement props feature to place your items.

---

## 🎮 Key Features

- 🎯 Modular system: Players can place various properties (baskets, machines, fans) as needed.
- 🧊 Engine heating and cooling system.
- ⏱️ Automatic time control, each machine makes money after a certain time.
- 💵 Supports `black money`, `money`, and `markedbills` (optional, customizable).
- 🖥️ Computer interface for managing the machine.
- 🚫 Anti-abuse: Can only install the machine if it is close to the main basket.

---

## 🧩 Config

Example settings from the `config.lua` file:

```lua
Config = {
    BlackMoneyItem = "blackmoney",
    MoneyItem = "money",
    UseMarkedBills = true,
    MarkedBillsItem = "markedbills",
    MachineMoneyCount = 2,
    MachineCoolingUp = 2,
    MachineCoolingDown = 2,
    MachineHeatingUp = 2,
    MachineHeatingDown = 2,
    ControlTime = 600,

    PropsAll = {
        [1] = {itemname = "v_res_fh_laundrybasket", label = "Laundry Basket", itemType="desk"},
        [2] = {itemname = "bkr_prop_prtmachine_dryer_spin", label = "Dryer Machine", itemType="miner"},
        [3] = {itemname = "v_res_fa_fan", label = "Fan 1", itemType="fan"},
    }
}
```

---

## 📷 Display Example
![mw1](https://github.com/user-attachments/assets/bc173175-53f6-47be-9da0-2a702b1ff72c)
![mw2](https://github.com/user-attachments/assets/ae4c4d71-0e4c-423a-a485-60d4a7946525)
![mw3](https://github.com/user-attachments/assets/431d4fc0-ad54-4bc9-978a-b0d8b93e632a)
![mw4](https://github.com/user-attachments/assets/b576a706-c006-47ef-82ff-dc7da1011e56)
![mw5](https://github.com/user-attachments/assets/b3744310-6545-4f13-a2b1-1ff95c55471a)


---

## 📦 Instalasi

1. Download or clone this script to your `resources/[local]/` folder:
   ```bash
   git clone https://github.com/username/exter-moneywash.git
   ```

2. Add to `server.cfg`:
   ```cfg
   ensure exter-moneywash
   ```

3. Edit `config.lua` according to server needs.

4. add this item to your server

## if you using qb-inventory
```
["v_res_fh_laundrybasket"] = {
    name = "v_res_fh_laundrybasket",
    label = "Laundry Basket",
    weight = 500,
    type = "item",
    image = "v_res_fh_laundrybasket.png",
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = "Tempat laundry, sebagai mesin utama"
},

["bkr_prop_prtmachine_dryer_spin"] = {
    name = "bkr_prop_prtmachine_dryer_spin",
    label = "Dryer Machine",
    weight = 700,
    type = "item",
    image = "bkr_prop_prtmachine_dryer_spin.png",
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = "Mesin pengering untuk laundry"
},

["v_res_fa_fan"] = {
    name = "v_res_fa_fan",
    label = "Fan 1",
    weight = 300,
    type = "item",
    image = "v_res_fa_fan.png",
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = "Kipas tambahan"
},

["prop_aircon_s_04a"] = {
    name = "prop_aircon_s_04a",
    label = "Fan 2",
    weight = 300,
    type = "item",
    image = "prop_aircon_s_04a.png",
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = "Kipas AC lama"
},

["v_ret_fh_fanltonbas"] = {
    name = "v_ret_fh_fanltonbas",
    label = "Fan 4",
    weight = 300,
    type = "item",
    image = "v_ret_fh_fanltonbas.png",
    unique = true,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = "Kipas industri"
},
```

## if you using ox_inventory

```
["v_res_fh_laundrybasket"] = {
    name = "v_res_fh_laundrybasket",
    label = "Laundry Basket",
    weight = 500,
    type = "item",
    image = "v_res_fh_laundrybasket.png",
    unique = true,
    useable = false,
    shouldClose = true,
    description = "Tempat laundry, sebagai mesin utama"
},

["bkr_prop_prtmachine_dryer_spin"] = {
    name = "bkr_prop_prtmachine_dryer_spin",
    label = "Dryer Machine",
    weight = 700,
    type = "item",
    image = "bkr_prop_prtmachine_dryer_spin.png",
    unique = true,
    useable = false,
    shouldClose = true,
    description = "Mesin pengering untuk laundry"
},

["v_res_fa_fan"] = {
    name = "v_res_fa_fan",
    label = "Fan 1",
    weight = 300,
    type = "item",
    image = "v_res_fa_fan.png",
    unique = true,
    useable = false,
    shouldClose = true,
    description = "Kipas tambahan"
},

["prop_aircon_s_04a"] = {
    name = "prop_aircon_s_04a",
    label = "Fan 2",
    weight = 300,
    type = "item",
    image = "prop_aircon_s_04a.png",
    unique = true,
    useable = false,
    shouldClose = true,
    description = "Kipas AC lama"
},

["v_ret_fh_fanltonbas"] = {
    name = "v_ret_fh_fanltonbas",
    label = "Fan 4",
    weight = 300,
    type = "item",
    image = "v_ret_fh_fanltonbas.png",
    unique = true,
    useable = false,
    shouldClose = true,
    description = "Kipas industri"
},
```

---

## 🛠️ Requirements

- QBCore Framework
- interact system [darktrovx](https://github.com/darktrovx/interact)
- plcement object system [object_gizmo](https://github.com/DemiAutomatic/object_gizmo)
- Notification system (default QBCore or custom)

---

## 📣 Credits

Created by [CLTRALTDELETE](https://github.com/CtrlAltDelete4413) — Developer of ExterFramework.

---

## ❗ Notes

This script is still under active development. Use it wisely and report bugs if found.
