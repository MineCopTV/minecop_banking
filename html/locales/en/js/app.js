var currentAccount = null;
var atmCard = null;
var numCards = 0;

function alert(message, messageType){
    $('#alert').hide();
    $('#alert').removeClass('alert-danger');
    $('#alert').removeClass('alert-success');
    if (messageType === true) $('#alert').addClass('alert-success');
    else $('#alert').addClass('alert-danger');
    $('#alert').text(message);
    $('#alert').show().delay(3000).fadeOut(300);
}

function bankOpenGeneral(){
    $('body').addClass('active');
    $('#mainBankPage, #bank').show();
}

function atmOpenGeneral(){
    $('body').addClass('active');
    $('#mainATMPage, #ATM, #mainDebitCards').show();
}

function bankOpen(bankId){
    $('.bank-page').hide();
    $(bankId).show();
}

function atmOpen(atmId){
    $('.atm-page').hide();
    $(atmId).show();
}

function atmKeyAction(action){
    $('.atm-btn').data("action", action);
}

function createContacts(contacts){
    if(contacts === undefined || contacts === null) return;
    var divContacts = document.getElementById("bankTransferContacts");
    divContacts.innerHTML = "";
    for (i = 0; i < contacts.length; i++) {
        var contact = contacts[i];
        var option =
            '<input type="radio" class="btn-check" name="contact" id="contact'+i+'" autocomplete="off" value="'+contact.number+'">' +
            '<label class="btn btn-outline-success mb-0 text-left" for="contact'+i+'">'+contact.name+' ('+contact.number.substring(0, 7)+'...)' +
            '   <button class="btn text-danger" id="btnTransferRemoveContact'+i+'"><i class="fas fa-user-minus fa-lg"></i></button>' +
            '</label>';
        divContacts.innerHTML += option;
        $("#btnTransferRemoveContact"+i).click(function(){
            $('#bankTransferTarget').val("");
            $.post('https://minecop_banking/removeTransferContact', JSON.stringify({
                login: currentAccount.login,
                target: contact.number
            }));
        });
    }
    $("input[name='contact']").change(function(){
        var radioValue = $("input[name='contact']:checked").val();
        if(radioValue) $('#bankTransferTarget').val(radioValue);
    });
}

function createDebitCards(cards){
    if(cards === undefined || cards === null) return;
    var divCards = document.getElementById("mainDebitCards");
    divCards.innerHTML = "";
    var top = 0;
    for (i = 0; i < cards.length; i++) {
        var card = cards[i];
        top = 0 + i*5;
        var style = 'background-image: url(img/atm-card-background-'+card.cardColor+'.png); right: 0; top: '+top+'%;';
        if(top > 80) break;
        var option = 
            '<div class="debit-card debit-card-drag" style="'+style+'" data-number="'+card.cardNumber+'" data-locked="'+card.cardLocked+'" data-removed="'+card.cardRemoved+'">' +
            '   <h4 class="debit-card-number">'+card.cardNumber+'</h4>' +
            '   <h4 class="debit-card-owner">'+card.account.name+'</h4>';
        if(card.cardPaypass === 1) option += '<img class="debit-card-paypass" src="img/atm-card-paypass.png" width="20px">';
        option += '</div>';
        divCards.innerHTML += option;
        numCards++;
    }
    $(function() {
        var a = numCards;
        $(".debit-card").draggable({
            containment: "document",
            start: function(event, ui) { 
                $(this).css("z-index", a++);
            }
        });
        $("#atmCardSlot").droppable({
            accept: ".debit-card",
            drop: function(event, ui) {
                if(atmCard !== null) return;
                var dragged = ui.draggable;
                atmPutCard(dragged, function(){
                    $.post('https://minecop_banking/putCardATM', JSON.stringify({
                        cardNumber: $(dragged).data("number"),
                        cardLocked: $(dragged).data("locked"),
                        cardRemoved: $(dragged).data("removed")
                    }));
                });
            }
        });
    });
}

function updateValues(){
    // BANK
    $('#bankDashboardBalance').text(currentAccount.balance);
    $('#bankDashboardPercent').text(currentAccount.percent);
    $('#bankDashboardName').val("Name: " + currentAccount.name);
    $('#bankDashboardAccountNumber').val("Number: " + currentAccount.number);
    $('#bankSettingsName').val("Name: " + currentAccount.name);
    $('#bankSettingsAccountNumber').val("Number: " + currentAccount.number);
    createContacts(currentAccount.contacts);
    if(currentAccount.card !== undefined){
        $('#btnSettingsCardGet').removeClass('disabled');
        $('#btnSettingsCardLock').removeClass('disabled');
        $('#btnSettingsCardSettingsSave').removeClass('disabled');
        $('#bankSettingsCardNumber').val("Number: " + currentAccount.card.number);
        $('#bankSettingsCardPIN').val("PIN: " + currentAccount.card.pin);
        $('#bankSettingsCardCardNumber').val("Number: " + currentAccount.card.number);
        $('#bankSettingsCardCardPIN').val("PIN: " + currentAccount.card.pin);
        $('#bankSettingsCardColor').val(currentAccount.card.color)
        $('#bankSettingsCardNewCardPIN').attr("placeholder", "PIN: " + currentAccount.card.pin);
        $('#bankSettingsCardPaypass').val(currentAccount.card.paypass);
        $('#bankSettingsCardPaypassLimit').attr("placeholder", "PayPass limit: " + currentAccount.card.paypassLimit + "$");
        if(currentAccount.card.locked === 1) {
            $('#btnSettingsCardLock').removeClass('btn-danger');
            $('#btnSettingsCardLock').addClass('btn-warning');
        } else {
            $('#btnSettingsCardLock').removeClass('btn-warning');
            $('#btnSettingsCardLock').addClass('btn-danger');
        }
    } else {
        $('#btnSettingsCardGet').addClass('disabled');
        $('#btnSettingsCardLock').addClass('disabled');
        $('#btnSettingsCardSettingsSave').addClass('disabled');
        $('#bankSettingsCardNumber').val("Here will be the card number");
        $('#bankSettingsCardPIN').val("Here will be the card PIN");
        $('#bankSettingsCardCardNumber').val("Here will be the card number");
        $('#bankSettingsCardCardPIN').val("Here will be the card PIN");
        $('#bankSettingsCardNewCardPIN').attr("placeholder", "Here will be the PIN");
        $('#bankSettingsCardPaypass').val(0);
        $('#bankSettingsCardPaypassLimit').attr("placeholder", "Here will be the PayPass limit");
    }
    if(currentAccount.isMain === 1) $('#btnSettingsMainAccount').addClass('disabled');
    else $('#btnSettingsMainAccount').removeClass('disabled');
    // ATM
    $('#dashboardATMName').text(currentAccount.name);
    $('#dashboardATMBalance').text(currentAccount.balance);
}

function logout(){
    if(currentAccount !== null){
        $.post('https://minecop_banking/logoutAccount', JSON.stringify({
            login: currentAccount.login
        }));
    }
}

function closeAll(){
    $('#alert, #mainBankPage, .bank-page, #mainATMPage, .atm-page, #mainPayPage, .pay-page, #mainDebitCards').hide();
    // BANK
    $('#bankRegisterUsername').val("");
    $('#bankRegisterPassword').val("");
    $('#bankRegisterBackupCode').val("");
    $('#bankRegisterType').val(0);
    $('#bankLoginUsername').val("");
    $('#bankLoginPassword').val("");
    $('#bankRecoverUsername').val("");
    $('#bankRecoverBackupCode').val("");
    $('#bankNewPasswordPassword').val("");
    $('#bankNewPasswordPasswordRepeat').val("");
    $('#bankDepositMoney').val("");
    $('#bankWithdrawMoney').val("");
    $('#bankTransferTarget').val("");
    $('#bankTransferMoney').val("");
    $('#bankSettingsCardNewCardPIN').val("");
    $('#bankSettingsCardPaypassLimit').val("");
    $('#bankSettingsRemoveBackupCode').val("");
    $('#bankTransferContactTarget').val("");
    $('#bankTransferContactName').val("");
    // ATM
    $('#loginATMPin').val("");
    $('#depositATMMoney').val("");
    $('#withdrawATMMoney').val("");
    // REST
    $('body').removeClass('active');
    logout();
    atmKeyAction("");
    currentAccount = null;
    atmCard = null;
    numCards = 0;
}

// NUI Messages
$(function(){
	window.addEventListener('message', (event) => {
		var msg = event.data;
		if (msg !== undefined) {
            if (msg.account !== undefined && msg.account !== null && msg.account.length !== 0){
                currentAccount = msg.account
                updateValues();
            }
            if (msg.cards !== undefined && msg.cards !== null && msg.cards.length !== 0){
                createDebitCards(msg.cards)
            }
            if (msg.message !== undefined && msg.message !== ""){
                alert(msg.message, msg.messageType)
            }
            if (msg.action !== undefined && msg.action !== ""){
                // Main Actions
                if (msg.action === "openBank") {
                    bankOpenGeneral();
                } else if (msg.action === "openATM"){
                    atmOpenGeneral();
                } else if (msg.action === "openPay"){
                    
                } else if (msg.action === "closeAll"){
                    closeAll();
                } 
                // Bank Events Actions
                if (msg.action === "bankRegister") {
                    bankOpen('#bankLogin');
                    $('#bankRegisterUsername').val("");
                    $('#bankRegisterPassword').val("");
                    $('#bankRegisterBackupCode').val("");
                    $('#bankRegisterType').val(0);
                } else if (msg.action === "bankLogin") {
                    bankOpen('#bankDashboard');
                    $('#bankLoginUsername').val("");
                    $('#bankLoginPassword').val("");
                } else if (msg.action === "bankRecover") {
                    bankOpen('#bankNewPassword');
                    $('#bankRecoverUsername').val("");
                    $('#bankRecoverBackupCode').val("");
                } else if (msg.action === "bankNewPassword") {
                    currentAccount = null;
                    bankOpen('#bank');
                    $('#bankNewPasswordPassword').val("");
                    $('#bankNewPasswordPasswordRepeat').val("");
                } else if (msg.action === "bankDeposit") {
                    bankOpen('#bankDashboard');
                    $('#bankDepositMoney').val("");
                    $('#depositATMMoney').val("");
                } else if (msg.action === "bankWithdraw") {
                    bankOpen('#bankDashboard');
                    $('#bankWithdrawMoney').val("");
                    $('#withdrawATMMoney').val("");
                } else if (msg.action === "bankTransfer") {
                    bankOpen('#bankDashboard');
                    $('#bankTransferTarget').val("");
                    $('#bankTransferMoney').val("");
                } else if (msg.action === "bankTransferAddContact") {
                    $('#bankTransferContactTarget').val("");
                    $('#bankTransferContactName').val("");
                } else if (msg.action === "bankSaveCard") {
                    $('#bankSettingsCardNewCardPIN').val("");
                    $('#bankSettingsCardPaypassLimit').val("");
                } else if (msg.action === "bankClose") {
                    currentAccount = null;
                    bankOpen('#bank');
                    $('#bankSettingsRemoveBackupCode').val("");
                }
                // ATM Events Actions
                if (msg.action === "atmPutCardLocked") {
                    atmOpen("#lockedCardATM");
                    atmGetCard(atmCard, function(){
                        setTimeout(function(){if(atmCard === null) atmOpen("#ATM");}, 3000);
                    });
                } else if (msg.action === "atmPutCard") {
                    atmOpen("#loginATM");
                    atmKeyAction("pin");
                }
            }
		}
	});
});

//
//  BANK
// 
$('#btnCloseBank').click(function(){
    $.post('https://minecop_banking/closeUI', JSON.stringify({}));
})
// Bank Main Page
$('#btnLogin').click(function(){
    bankOpen('#bankLogin');
})
$('#btnRegister').click(function(){
    bankOpen('#bankRegister');
})
$('#btnRecover').click(function(){
    bankOpen('#bankRecover');
})
$('#btnLoginBack, #btnRegisterBack, #btnRecoverBack, #btnNewPasswordBack').click(function(){
    currentAccount = null;
    bankOpen('#bank');
})
// Bank Register Page
$('#bankRegister').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/openAccount', JSON.stringify({
        login: $('#bankRegisterUsername').val(),
        password: $('#bankRegisterPassword').val(),
        backupCode: $('#bankRegisterBackupCode').val(),
        type: $('#bankRegisterType').val()
    }));
})
// Bank Login Page
$('#bankLogin').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/loginAccount', JSON.stringify({
        login: $('#bankLoginUsername').val(),
        password: $('#bankLoginPassword').val()
    }));
})
// Bank Recover Page
$('#bankRecover').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/recoverAccount', JSON.stringify({
        login: $('#bankRecoverUsername').val(),
        backupCode: $('#bankRecoverBackupCode').val()
    }));
})
// Bank New Password Page
$('#bankNewPassword').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/newPasswordAccount', JSON.stringify({
        login: currentAccount.login,
        password: $('#bankNewPasswordPassword').val(),
        passwordRepeat: $('#bankNewPasswordPasswordRepeat').val()
    }));
})
// Bank Dashboard
$('#btnDashboardDeposit').click(function(){
    bankOpen('#bankDeposit');
})
$('#btnDashboardWithdraw').click(function(){
    bankOpen('#bankWithdraw');
})
$('#btnDashboardTransfer').click(function(){
    bankOpen('#bankTransfer');
})
$('#btnDashboardSettings').click(function(){
    bankOpen('#bankSettings');
})
$('#btnDashboardLogout').click(function(){
    logout();
    currentAccount = null;
    bankOpen('#bank');
})
$('#btnSettingsBack, #btnDepositBack, #btnWithdrawBack, #btnTransferBack').click(function(){
    bankOpen('#bankDashboard');
})
// Bank Deposit
$('#bankDeposit').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/deposit', JSON.stringify({
        login: currentAccount.login,
        money: $('#bankDepositMoney').val()
    }));
})
// Bank Withdraw
$('#bankWithdraw').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/withdraw', JSON.stringify({
        login: currentAccount.login,
        money: $('#bankWithdrawMoney').val()
    }));
})
// Bank Transfer
$('#btnTransferAddContact').click(function(){
    $.post('https://minecop_banking/addTransferContact', JSON.stringify({
        login: currentAccount.login,
        target: $('#bankTransferContactTarget').val(),
        name: $('#bankTransferContactName').val()
    }));
})
$('#bankTransfer').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/transfer', JSON.stringify({
        login: currentAccount.login,
        target: $('#bankTransferTarget').val(),
        money: $('#bankTransferMoney').val()
    }));
})
// Bank Settings
$('#btnSettingsCard').click(function(){
    bankOpen('#bankSettingsCard');
})
$('#btnSettingsMainAccount').click(function(){
    $.post('https://minecop_banking/setMainAccount', JSON.stringify({
        owner: currentAccount.owner,
        login: currentAccount.login,
        isMain: currentAccount.isMain
    }));
})
$('#btnSettingsRemove').click(function(){
    bankOpen('#bankSettingsRemove');
})
$('#btnSettingsRemoveBack, #btnSettingsCardBack').click(function(){
    bankOpen('#bankSettings');
})
// Bank Card
$('#bankSettingsCard').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/saveCardSettings', JSON.stringify({
        login: currentAccount.login,
        card: currentAccount.card,
        newPin: $('#bankSettingsCardNewCardPIN').val(),
        color: $('#bankSettingsCardColor').val(),
        paypass: $('#bankSettingsCardPaypass').val(),
        paypassLimit: $('#bankSettingsCardPaypassLimit').val()
    }));
})
$('#btnSettingsCardGet').click(function(){
    $.post('https://minecop_banking/getDuplicateCard', JSON.stringify({
        login: currentAccount.login
    }));
})
$('#btnSettingsCardGetNew').click(function(){
    $.post('https://minecop_banking/getNewCard', JSON.stringify({
        login: currentAccount.login
    }));
})
$('#btnSettingsCardLock').click(function(){
    $.post('https://minecop_banking/lockCard', JSON.stringify({
        login: currentAccount.login,
        card: currentAccount.card
    }));
})
// Bank Remove
$('#bankSettingsRemove').submit(function(e){
    e.preventDefault();
    $.post('https://minecop_banking/closeAccount', JSON.stringify({
        login: currentAccount.login,
        backupCode: $('#bankSettingsRemoveBackupCode').val()
    }));
})
// 
//  ATM
// 
$('.atm-btn').click(function(){
    var audio = new Audio('../html/sounds/atm-click.ogg');
    audio.volume = 0.1;
    audio.play();
    var val = $(this).data('value');
    if(!val) return;
    var action = $(this).data('action');
    if(!action) return;
    if(action === "pin"){
        if(val === "action1" || val === "action2" || val === "action3" || val === "action4"
            || val === "back" || val === "accept" || val === "00" || val === "000") return;
        else if(val === "backspace"){
            $('#loginATMPin').val($('#loginATMPin').val().slice(0, -1));
            return;
        }
        else if(val === "zero") val = 0;
        $('#loginATMPin').val($('#loginATMPin').val() + val);
        if($('#loginATMPin').val().length < 4) return;
        if(currentAccount.card.pin !== $('#loginATMPin').val()){
            $('#loginATMPin').val("");
            atmKeyAction("");
            atmOpen("#wrongPinATM");
            atmGetCard(atmCard, function(){
                setTimeout(function(){if(atmCard === null) atmOpen("#ATM");}, 3000);
            });
            return;
        }
        $('#loginATMPin').val("");
        atmKeyAction("dashboard");
        atmOpen("#dashboardATM");
    } else if(action === "dashboard"){
        if(val === "action1"){
            atmKeyAction("deposit");
            atmOpen("#depositATM");
        } else if(val === "action2"){
            atmKeyAction("withdraw");
            atmOpen("#withdrawATM");
        } else if(val === "action3"){
            
        }
    } else if(action === "deposit"){
        if(val === "action1" || val === "action2" || val === "action3" || val === "action4") return;
        else if(val === "backspace"){
            $('#depositATMMoney').val($('#depositATMMoney').val().slice(0, -1));
            return;
        }
        else if(val === "back"){
            $('#depositATMMoney').val("");
            atmKeyAction("dashboard");
            atmOpen("#dashboardATM");
            return;
        }
        else if(val === "accept"){
            if($('#depositATMMoney').val() > 100000){
                $('#depositATMMoney').val("");
                atmKeyAction("error");
                atmOpen("#errorATM");
                return;
            }
            $.post('https://minecop_banking/deposit', JSON.stringify({
                login: currentAccount.login,
                money: $('#depositATMMoney').val()
            }));
            return;
        }
        else if(val === "zero") val = 0;
        $('#depositATMMoney').val($('#depositATMMoney').val() + val);
    } else if(action === "withdraw"){
        if(val === "action1" || val === "action2" || val === "action3" || val === "action4") return;
        else if(val === "backspace"){
            $('#withdrawATMMoney').val($('#withdrawATMMoney').val().slice(0, -1));
            return;
        }
        else if(val === "back"){
            $('#withdrawATMMoney').val("");
            atmKeyAction("dashboard");
            atmOpen("#dashboardATM");
            return;
        }
        else if(val === "accept"){
            if($('#withdrawATMMoney').val() > 100000){
                $('#withdrawATMMoney').val("");
                atmKeyAction("error");
                atmOpen("#errorATM");
                return;
            }
            $.post('https://minecop_banking/withdraw', JSON.stringify({
                login: currentAccount.login,
                money: $('#withdrawATMMoney').val()
            }));
            return;
        }
        else if(val === "zero") val = 0;
        $('#withdrawATMMoney').val($('#withdrawATMMoney').val() + val);
    } else if(action === "error"){
        atmKeyAction("dashboard");
        atmOpen("#dashboardATM");
    }
})
$('#btnATMLogout').click(function(){
    if(atmCard === null) return;
    atmKeyAction("");
    atmGetCard(atmCard, function(){
        atmOpen("#ATM");
    }); 
})
// Utilities
function atmPutCard(card, callback){
    var audio = new Audio('../html/sounds/atm-card.ogg');
    audio.volume = 0.3;
    $(card).animate({left: 1050, top: 200},300,function(){}).animate({deg: 90}, {
        duration: 300,
        step: function(now) {
            card.css({transform: 'rotate(' + now + 'deg)'});
    }}).animate({deg2: 75}, {
        duration: 300,
        step: function(now) {
            card.css({transform: 'rotate(90deg) rotate3d(0,1,0,' + now + 'deg)'});
        },
        complete: function(){
            audio.play();
    }}).animate({top:140,opacity:0}, 300, function(){
        atmCard = card;
        callback();
    });
}

function atmGetCard(card, callback){
    var audio = new Audio('../html/sounds/atm-card.ogg');
    audio.volume = 0.3;
    audio.play();
    $(card).css("left", "1050px").css("top", "200").animate({top:200,opacity:1}, 300, function(){}).animate({deg2: 0}, {
        duration: 300,
        step: function(now) {
            card.css({transform: 'rotate(90deg) rotate3d(0,1,0,' + now + 'deg)'});
    }}).animate({deg: 0}, {
        duration: 300,
        step: function(now) {
            card.css({transform: 'rotate(' + now + 'deg)'});
        },
        complete: function(){
            currentAccount = null;
            atmCard = null;
            callback();
        }
    });
}

document.onkeyup = function(data){
    if (data.which == 27){
        $.post('https://minecop_banking/closeUI', JSON.stringify({}));
    }
}