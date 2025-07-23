const redis = require('redis');
const { performance } = require('perf_hooks');

async function run() {
  const client = redis.createClient({ url: 'redis://localhost:6380' });

  client.on('error', (err) => {
    console.error('Redis error:', err);
  });
  await client.connect();
  console.log("Подключено к Redis");
  const count = 10000;

  // HSET 
  const t1 = performance.now();
  for (let i = 1; i <= count; i++) {
    await client.hSet(`user${i}`, {
      id: `${i}`,
      val: `val-${i}`
    });
  }
  const t2 = performance.now();

  // HGETALL 
  const t3 = performance.now();
  for (let i = 1; i <= count; i++) {
    await client.hGetAll(`user${i}`);
  }
  const t4 = performance.now();

  await client.quit();

  console.log('\nРезультаты выполнения 10 000 HSET и HGET:\n');
  console.table([
    { Операция: 'HSET (user{i}, {id, val})', 'Время (мс)': (t2 - t1).toFixed(2) },
    { Операция: 'HGETALL (user{i})', 'Время (мс)': (t4 - t3).toFixed(2) },
  ]);
}

run();
