let cart = [];

function addToCart(nome, preco) {
    cart.push({ nome, preco });
    updateCartUI();
    if(!document.getElementById('cart-sidebar').classList.contains('active')) {
        toggleCart();
    }
}

function updateCartUI() {
    document.getElementById('cart-count').innerText = cart.length;
    const container = document.getElementById('cart-items');
    container.innerHTML = "";
    let total = 0;

    cart.forEach((item, index) => {
        total += item.preco;
        container.innerHTML += `
            <div class="item-linha">
                <span>${item.nome}</span>
                <span>R$ ${item.preco.toFixed(2)}</span>
            </div>
        `;
    });

    document.getElementById('cart-total').innerText = `R$ ${total.toFixed(2)}`;
}

function toggleCart() {
    document.getElementById('cart-sidebar').classList.toggle('active');
}

function enviarWhatsApp() {
    if (cart.length === 0) return alert("Carrinho vazio!");
    
    const numero = "5573999999999"; // Seu número Bahia
    let texto = "*Novo Pedido - Loja Online*\n\n";
    
    cart.forEach(i => texto += `• ${i.nome} (R$ ${i.preco.toFixed(2)})\n`);
    texto += `\n*Total: ${document.getElementById('cart-total').innerText}*`;
    
    window.open(`https://wa.me/${numero}?text=${encodeURIComponent(texto)}`);
}
