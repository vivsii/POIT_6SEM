const redis = require('redis');

async function testRedisConnection() {
  const client = redis.createClient({
    url: 'redis://localhost:6380' 
  });

  client.on('error', (err) => {
    console.error('Ошибка соединения с Redis:', err);
  });

  try {
    await client.connect();
    console.log('Соединение с Redis установлено успешно.');
    await client.quit();
    console.log('Соединение с Redis закрыто.');
  } catch (err) {
    console.error('Ошибка при работе с Redis:', err);
  }
}

testRedisConnection();
