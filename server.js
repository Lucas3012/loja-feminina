const express = require('express');
const fs = require('fs');
const path = require('path');
const session = require('express-session');

const app = express();

// Configurações
app.set('view engine', 'ejs');
app.use(express.static('public'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: 'chave-secreta-itabuna',
    resave: false,
    saveUninitialized: true
}));

// Credenciais Administrativas
const CREDENCIAIS = { usuario: "admin", senha: "123" };

// Funções de Banco de Dados Local
const lerBanco = (arquivo) => {
    if (!fs.existsSync(arquivo)) fs.writeFileSync(arquivo, '[]');
    return JSON.parse(fs.readFileSync(arquivo, 'utf-8'));
};

const salvarBanco = (arquivo, dados) => {
    fs.writeFileSync(arquivo, JSON.stringify(dados, null, 2));
};

// Middleware de Proteção
function verificarLogin(req, res, next) {
    if (req.session.logado) return next();
    res.redirect('/login');
}

// --- ROTAS PÚBLICAS ---

app.get('/', (req, res) => {
    const produtos = lerBanco('./produtos.json');
    res.render('index', { produtos });
});

app.get('/login', (req, res) => {
    res.render('login', { erro: null });
});

app.post('/login', (req, res) => {
    const { usuario, senha } = req.body;
    if (usuario === CREDENCIAIS.usuario && senha === CREDENCIAIS.senha) {
        req.session.logado = true;
        res.redirect('/admin');
    } else {
        res.render('login', { erro: "Acesso negado!" });
    }
});

app.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/');
});

// Finalizar pedido (salva no histórico antes do WhatsApp)
app.post('/finalizar-pedido', (req, res) => {
    const pedidos = lerBanco('./pedidos.json');
    const novoPedido = {
        id: Date.now(),
        data: new Date(),
        ...req.body
    };
    pedidos.push(novoPedido);
    salvarBanco('./pedidos.json', pedidos);
    res.json({ success: true, id: novoPedido.id });
});

// --- ROTAS ADMINISTRATIVAS ---

app.get('/admin', verificarLogin, (req, res) => {
    const produtos = lerBanco('./produtos.json');
    const pedidos = lerBanco('./pedidos.json');
    res.render('admin', { produtos, pedidos });
});

app.post('/admin/add', verificarLogin, (req, res) => {
    const produtos = lerBanco('./produtos.json');
    produtos.push({
        id: Date.now(),
        nome: req.body.nome,
        preco: parseFloat(req.body.preco),
        img: req.body.img
    });
    salvarBanco('./produtos.json', produtos);
    res.redirect('/admin');
});

app.post('/admin/delete/:id', verificarLogin, (req, res) => {
    let produtos = lerBanco('./produtos.json');
    produtos = produtos.filter(p => p.id != req.params.id);
    salvarBanco('./produtos.json', produtos);
    res.redirect('/admin');
});

app.get('/recibo/:id', verificarLogin, (req, res) => {
    const pedidos = lerBanco('./pedidos.json');
    const pedido = pedidos.find(p => p.id == req.params.id);
    if (!pedido) return res.send("Pedido não encontrado.");
    res.render('recibo', { pedido });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Servidor rodando em http://localhost:${PORT}`));
