import express from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/heal', (req, res) => {
  res.json({ message: 'Self-healing platform active' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
