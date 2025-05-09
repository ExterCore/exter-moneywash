let connectingDiv = null;
let max_value = 350;
let countdownTime = 600;

const canvas = document.getElementById('lineCanvas');
const ctx = canvas.getContext('2d');

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

let dragging = false;
let startX, startY, endX, endY;

window.addEventListener("message", function (e) {
    $("body").fadeIn(500);
    e = e.data
    switch (e.action) {
    case "openProps":
        return openProps(e.data)
    case "setPropsData":
        return setPropsData(e.data)
    case "openControl":
        return controlPanel(e.data)
    case "open":
        return openWashing(e.data)
    default:
    return;
    }
});


function updateMoneyDisplay(moneyValue) {
    var moneyStr = moneyValue.toString();
    
    while (moneyStr.length < 4) {
        moneyStr = '0' + moneyStr;
    }
    
    var moneyAlts = document.querySelectorAll('.money-box .money-alt');
    
    moneyAlts[0].textContent = '$';

    // add id first money box

    moneyAlts[0].id = "money-box-1";
    
    for (var i = 1; i < moneyAlts.length; i++) {
        moneyAlts[i].textContent = moneyStr.charAt(i - 1);
    }
}



function generateRandomValue(baseValue, variation) {
    const min = Math.max(baseValue - variation, 0);
    const max = Math.min(baseValue + variation, max_value);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function updateStatsItem(statsItem, data) {
    const statsCool = statsItem.querySelector('.stats-cool');
    const statsHeating = statsItem.querySelector('.stats-heating');
    const statsPerformance = statsItem.querySelector('.stats-performance');

    const coolHeight = (data.cooling / max_value) * 100;
    const heatingHeight = (data.heating / max_value) * 100;
    const performanceHeight = (data.performance / max_value) * 100;

    statsCool.style.height = `${coolHeight}%`;
    statsCool.style.top = `${100 - coolHeight}%`;

    statsHeating.style.height = `${heatingHeight}%`;
    statsHeating.style.top = `${100 - heatingHeight}%`;

    statsPerformance.style.height = `${performanceHeight}%`;
    statsPerformance.style.top = `${100 - performanceHeight}%`;
}


function updateStats(machine_data) {
    const statsItems = document.querySelectorAll('.stats-item');
    const baseVariations = [50, 60, 70, 80, 90, 100, 110, 120, 130, 140];
    
    updateStatsItem(statsItems[0], machine_data);

        for (let i = 1; i < statsItems.length; i++) {
            const variation = baseVariations[i - 1]; 
            const randomData = {
                cooling: generateRandomValue(machine_data.cooling, variation),
                heating: generateRandomValue(machine_data.heating, variation),
                performance: generateRandomValue(machine_data.performance, variation),
                money: generateRandomValue(machine_data.money, variation)
            };
            updateStatsItem(statsItems[i], randomData);
        }
}


function drawCurvedLine(x1, y1, x2, y2,first) {

    if (first!=true) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
    }

    const controlX = (x1 + x2) / 2;
    const controlY = y1 < y2 ? y1 - Math.abs(y1 - y2) / 2 : y2 - Math.abs(y1 - y2) / 2;

    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.quadraticCurveTo(controlX, controlY, x2, y2);
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.10)';
    ctx.lineWidth = 2;
    ctx.stroke();
}

function getDivCenter(div) {
    const rect = div.getBoundingClientRect();
    return {
        x: rect.left + rect.width / 2,
        y: rect.top + rect.height / 2
    };
}

document.querySelectorAll('.machine-dot').forEach(div => {
    div.addEventListener('mousedown', function (e) {
        const center = getDivCenter(div);
        startX = center.x;
        startY = center.y;
        dragging = true;

    });
});



document.addEventListener('mousemove', (e) => {
    if (dragging) {
        endX = e.clientX;
        endY = e.clientY;
        drawCurvedLine(startX-2, startY-2, endX-2, endY-2);
    }
});


function drawCanvas(data) {
    data = canvasData;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawCurvedLine(data.startX, data.startY, data.endX, data.endY);
}

$(document).mouseup(function(e) {
    if (dragging) {
        var div2Rect = div2.getBoundingClientRect();
        if (e.clientX >= div2Rect.left && e.clientX <= div2Rect.right && e.clientY >= div2Rect.top && e.clientY <= div2Rect.bottom) {
            var connectingElement = $("#" + connectingDiv);
            var machineItemDiv = connectingElement.closest('.machine-item');
            var objId = machineItemDiv.data('item');

            var canvasData = {
                startX: startX,
                startY: startY,
                endX: endX,
                endY: endY,
                width: canvas.width,
                height: canvas.height,
                objId: objId
            }
            if (machineItemDiv.length) {
                $.post('http://exter-moneywash/connected', JSON.stringify({id: objId, canvasData: canvasData}), function (response) {
                    if (response != false) {
                        $.post('http://exter-moneywash/setCanvas', JSON.stringify({canvasData: canvasData}), function (canvasDataResponse) {
                            if (canvasDataResponse != false) {
                                ctx.clearRect(0, 0, canvas.width, canvas.height);
                                canvasDataResponse.forEach(item => {
                                    item['canvas'].forEach(line => {
                                        drawCurvedLine(line.startX - 2, line.startY - 2, line.endX - 2, line.endY - 2, true);
                                    });
                                });
                            }
                        });
                    }
                });
            }
            
            var div2Center = getDivCenter(div2);
            endX = div2Center.x;
            endY = div2Center.y;
            drawCurvedLine(startX - 2, startY - 2, endX - 2, endY - 2);
        } else {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
        }
        dragging = false;
    }
});


function controlPanel(data) {
    let sendData = data.sendData;
    
    let minerItems = sendData.filter(item => item.itemType === 'miner');


    $('.machine-box').empty();

    $('.machine-box').append(`
        <div  class="machine-basket">
            <div id="divbasket" class="machine-basket-dot"></div>
            <div class="machine-basket-name">Basket <span style="color: #E1BD41;">#1</span></div>
          </div>`
    );

    if (minerItems.length == 0) {
        $('.machine-item').hide();
    }else{
        $('.machine-item').show();
        for (let i = 0; i < minerItems.length; i++) {
            $('.machine-box').append(`
                <div draggable="true" data-item='${JSON.stringify(minerItems[i].objId)}' class="machine-item ui-draggable">
                    <div class="machine-name">Machine <span style="color: #00F7BE;">#${[i+1]}</span></div>
                    <div id="div${[i+1]}" class="machine-dot"></div>
                </div>
            `);
        }
        document.querySelectorAll('.machine-dot').forEach(div => {
            div.addEventListener('mousedown', function (e) {
                const center = getDivCenter(div);
                startX = center.x;
                startY = center.y;
                dragging = true;
                connectingDiv = div.id;

            });
        });

         div2 = document.getElementById('divbasket');
    }
    
    $('.control-box , body').show();
    $('.washing-box , .create-prop-page').hide();

    let canvasData = data.canvasData;

    if (canvasData) {
        $.each(canvasData, function (i, v) {
            drawCurvedLine(v.startX-2, v.startY-2, v.endX-2, v.endY-2,true);
        })
    }
}


function openWashing(data) {
    $('body , .washing-box').show();    
    $('.control-box , .create-prop-page').hide();

    minerLength = 0;

    $.each(data, function (i, v) {
        if (v.props && Array.isArray(v.props)) {
            var minerItems = v.props.filter(function(y) {
                return y.itemType == "miner";
            });


            var linkedItems = v.props.filter(function(y) {
                return y.linked === true;
            });

            if (linkedItems.length > 0) {
                $('#machine-linkedCount').text(linkedItems.length+"x");
            }else{
                $('#machine-linkedCount').text("0x");
            }

            if (minerItems.length > 0) {
                $('#machine-count').text(minerItems.length+"x");
            }else{
                $('#machine-count').text("0x");
            }

        }

        if (v.machine_data ) {
            updateStats(v.machine_data);
            var performancePercentage = (v.machine_data.performance / max_value) * 90;
            var hourlyMoney = v.machine_data.time;  
            $('#hourly-money').text(`$${hourlyMoney} / h`);
            $('.performance-progress').css('width', `${performancePercentage}%`);
            updateMoneyDisplay(v.machine_data.money);
        }

    });
}


function updateCountdown() {
    var minutes = Math.floor(countdownTime / 60);
    var seconds = countdownTime % 60;
    
    var countdownText = minutes + 'm ' + seconds.toString().padStart(2, '0') + 's';
    
    document.getElementById('countdown').textContent = countdownText;
    
    countdownTime--;
    
    if (countdownTime < 0) {
        clearInterval(timer);        
        countdownTime = 600;
        timer = setInterval(updateCountdown, 1000); 
    }
}

updateCountdown();

var timer = setInterval(updateCountdown, 1000);



function openProps(data) { 
    $(".prop-box").empty();
    $(".create-prop-page").show();
    $('.washing-box,.control-box').hide();
    $.each(data, function (i, v) {
        $(".prop-box").append(`
        <div data-itemname="${v.itemname}" data-hash="${v.hash}" data-propname="${v.propname}" class="prop-item">
            <img src="../images/${v.propname}.png" class="prop-img" alt="">
            <div class="prop-item-name">${v.label}</div>
            <div class="right-box">></div>
        </div>
        `)
    })
}

function setPropsData(data) {
    $('.posx').html(data["position"]["x"]);
    $('.posy').html(data["position"]["y"]);
    $('.posz').html(data["position"]["z"]);
    $('.rotx').html(data["rotation"]["x"]);
    $('.roty').html(data["rotation"]["y"]);
    $('.rotz').html(data["rotation"]["z"]);
}



window.addEventListener('resize', () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
});


$(document).on('click', '#money-box-1', function (e) {
    // Handle the click event
    $.post(`http://exter-moneywash/withdrawMoney`, JSON.stringify({ }), function (x) {
        if (x == true) {
            updateMoneyDisplay(0);
        }
    });
});

// Add hover effect on mouse enter and leave
$(document).on('mouseenter', '#money-box-1', function () {
    $(this).css({
        'background-color': 'rgba(0, 135, 108, 0.50)',  // Change background color
        'transform': 'scale(1.08)',                      // Apply scale effect
        'cursor': 'pointer'                              // Change cursor to pointer
    });
});

$(document).on('mouseleave', '#money-box-1', function () {
    $(this).css({
        'background-color': '',  // Reset background color
        'transform': '',          // Remove scale effect
        'cursor': ''              // Reset cursor
    });
});


$(document).on('click', '.prop-item', function (e) {
    $(".prop-item").css({'background-color': '#2f3137','opacity': '0.7'});
    
    $(".prop-item-name").css('color', '#fff');
    
    $(".right-box").css({'background-color': '#296b5f','color': '#0ceebf'});

    $(this).css({'background-color': '#296b5f','opacity': '1'});

    $(this).find(".prop-item-name").css('color', '#0ceebf');

    $(this).find(".right-box").css({'background-color': '#0ceebf','color': '#296b5f'});

    itemName = $(this).data("itemname");
    propName = $(this).data("propname");
    hash = $(this).data("hash");
    $.post(`http://exter-moneywash/openProps`, JSON.stringify({itemName:itemName,propName:propName,hash:hash}), function (x) {
        if (x=='openProps') {
            
        }
    })

    $(".select-item-img,.create-prop-img").attr('src', `../images/${propName}.png`);

    $(".select-item-name-box,.create-prop-name-box").text(itemName);
    $(".propmodel").text(propName);
    $(".hashbox").text(hash);
})

$(".prop-search-input").on("input", function () {
    var searchTerm = $(this).val().toLowerCase();
    $(".prop-item").each(function () {
        var propName = $(this).find(".prop-item-name").text().toLowerCase();
        if (propName.includes(searchTerm)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        $("body").fadeOut(500);
        $.post(`http://exter-moneywash/close`, JSON.stringify({ }), function (x) {});
    }
});


$(document).on('click', '.prop-settings', function (e) {
    $('.prop-popup').fadeOut(300);
    dataType = $(this).data("type");
    $('.'+dataType+'-pop-up').fadeIn(300);

    if (dataType=="delete") {
        $.post(`http://exter-moneywash/deleteProp`, JSON.stringify({ }), function (x) {});
    }

})

$(document).on('click', '.prop-popup .leave-button', function (e) {
    $("body").fadeOut(500);
    $.post(`http://exter-moneywash/close`, JSON.stringify({ }), function (x) {});
    $.post(`http://exter-moneywash/deleteProp`, JSON.stringify({ }), function (x) {});
    
})

$(document).on('click', '.prop-popup .cancel-button', function (e) {
    $(".prop-popup").fadeOut(300);
})

$(document).on('click', '.save-build-button', function (e) {
    $(".prop-popup").fadeOut(300);
    // $('.computer-build').fadeIn(300);
    $.post(`http://exter-moneywash/saveBuild`, JSON.stringify({ }), function (x) {});
})

$(document).on('click', '.discard-button', function (e) {
    $(".prop-popup").fadeOut(300);
    $.post(`http://exter-moneywash/deleteProp`, JSON.stringify({ }), function (x) {});
})
