Config = {
    ServerCallbacks = {},
    BlackMoneyItem = "blackmoney",
    BlackMoneyDecrease = 100,
    MoneyItem = "money",
    MachineMoneyCount = 2,   --It determines how much money each washing machine will give at the specified number of minutes. For example, if you have 3 machines, the system automatically multiplies this amount by 3
    MachineCoolingUp = 2, --Your machine determines how much it will cool down in the specified time, values vary according to the number of fans
    MachineCoolingDown = 2, --Your machine determines how much it will cool down in the specified time, values vary according to the number of fans
    MachineHeatingDown = 2, --Your machine determines how much it will heat up in the specified time, values vary according to the number of fans
    MachineHeatingUp = 2, --Your machine determines how much it will heat up in the specified time, values vary according to the number of fans
    UseMarkedBills = true, -- For qb
    MarkedBillsItem = "markedbills", -- For qb
    ControlTime = 600, --The time it takes to control the machine


    HackText = "Open Basket", --Articles about texts are written here
    GeneralDataText = "Open General data", --Articles about texts are written here
    BuildText = "Control Panel", --Articles about texts are written here
    MinerDistance = 30.0, --The distance value is how close to the computer you want the miner to be when you install it.


    Notify = {
        ["pcControl"] = {
            msgType = "error",
            text = "While there is a desk, the item to be added should not be a machine.",
            length = 5000
        },
        ["minerControl"] = {
            msgType = "error",
            text = "To add a washing machine, you need to be close to the desk.",
            length = 5000
        },
        ["minerSuccess"] = {
            msgType = "success",
            text = "Added because you are close to the desk.",
            length = 5000
        },
        ["distanceControl"] = {
            msgType = "error",
            text = "First approach the machine and establish connection.",
            length = 5000
        },
        ["firstItemControl"] = {
            msgType = "error",
            text = "The first item to be added must be a desk.",
            length = 5000
        },
        ["alreadyPc"] = {
            msgType = "error",
            text = "You already have one desk.",
            length = 5000
        }

    },
    PropsAll = {
        [1] = {itemname = "v_res_fh_laundrybasket", label = "Laundry Basket", hash = "698127650" ,itemType="desk" ,  propname = "v_res_fh_laundrybasket" },
        [2] = {itemname = "bkr_prop_prtmachine_dryer_spin", label = "Dryer Machine", hash = "769275872" ,itemType="miner" ,  propname = "bkr_prop_prtmachine_dryer_spin"},
        [3] = {itemname = "v_res_fa_fan", label = "Fan 1", hash = "684271492" ,itemType="fan" ,  propname = "v_res_fa_fan"},
        [4] = {itemname = "prop_aircon_s_04a", label = "Fan 2", hash = "217291359" ,itemType="fan" ,  propname = "prop_aircon_s_04a"},
        [5] = {itemname = "v_ret_fh_fanltonbas", label = "Fan 4", hash = "2049937797" ,itemType="fan" ,  propname = "v_ret_fh_fanltonbas"},
    },
    Props = {
        "v_res_fh_laundrybasket",
        "v_res_fa_fan",
        "bkr_prop_prtmachine_dryer_spin",
    },
}