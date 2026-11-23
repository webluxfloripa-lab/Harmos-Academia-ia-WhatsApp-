export function normalizePhone(value) { return String(value).replace(/\D/g, ''); }
export function validateProfile(name, phone) {
 if (name.trim().length < 3 || name.trim().length > 120) return 'Informe seu nome completo (3 a 120 caracteres).';
 if (!/^\d{10,11}$/.test(normalizePhone(phone))) return 'Informe um telefone brasileiro com DDD.';
 return null;
}
export function money(cents) { return (cents/100).toLocaleString('pt-BR',{style:'currency',currency:'BRL'}); }
