
const TelegramBot = require('node-telegram-bot-api');

const token = '7851594711:AAHNXlbmu-2FcU20ep8TOThGSribW7u9b4s';

const bot = new TelegramBot(token, { polling: true });

bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, 'привет, пиши сообщение, а я буду повторять за тобой');
});

bot.on('message', (msg) => {
  const chatId = msg.chat.id;
  const text = msg.text;

  if (text.startsWith('/start')) return;

  bot.sendMessage(chatId, `${text}`);
});
