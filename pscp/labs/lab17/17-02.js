const redis = require('redis');
const { performance } = require('perf_hooks');

async function benchmarkRedisOperations() {
  const client = redis.createClient({
      url: 'redis://localhost:6380' 
    });
  client.on('error', (err) => {
    console.error('Ошибка Redis:', err);
  });
  await client.connect();

  const count = 10000;
  const keys = Array.from({ length: count }, (_, i) => `key${i + 1}`);
  // SET
  const t1 = performance.now();
  await Promise.all(
    keys.map((key, i) => client.set(key, `set${i + 1}`))
  );
  const t2 = performance.now();

  // GET
  const t3 = performance.now();
  await Promise.all(
    keys.map((key) => client.get(key))
  );
  const t4 = performance.now();

  // DEL
  const t5 = performance.now();
  await Promise.all(
    keys.map((key) => client.del(key))
  );
  const t6 = performance.now();
  await client.quit();
  console.log('\nРезультаты тестирования Redis (10000 операций):\n');
  console.table([
    { Операция: 'SET', 'Время (мс)': (t2 - t1).toFixed(2) },
    { Операция: 'GET', 'Время (мс)': (t4 - t3).toFixed(2) },
    { Операция: 'DEL', 'Время (мс)': (t6 - t5).toFixed(2) },
  ]);
}

benchmarkRedisOperations();