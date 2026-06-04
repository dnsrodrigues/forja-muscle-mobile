/* global React, Icon, MobStatus, Phone, MobHead, BackHead, ShaderBackdrop */
// Onboarding (carousel state) + Login/Cadastro

function Onboarding() {
  return (
    <div className="mob" data-screen-label="Onboarding — Mobile" style={{ background:'#050506' }}>
      <MobStatus/>
      {/* Art / shader area */}
      <div style={{ position:'relative', height: 340, overflow:'hidden', display:'flex', alignItems:'flex-end', padding: 28 }}>
        <ShaderBackdrop intensity={1.0}/>
        <div style={{
          position:'absolute', inset:0, pointerEvents:'none',
          background:'linear-gradient(180deg, rgba(5,5,6,0.1) 0%, rgba(5,5,6,0.2) 50%, #050506 100%)',
        }}/>
        <div style={{ position:'relative' }}>
          <div className="eyebrow" style={{ color:'var(--accent)' }}>FORJA · 01 / 03</div>
        </div>
      </div>

      <div style={{ flex:1, display:'flex', flexDirection:'column', padding:'22px 28px 0', minHeight: 0 }}>
        <h1 className="f-display" style={{ fontSize: 56, lineHeight: 0.96, margin: '0' }}>
          REGISTRE<br/>CADA <span style={{ color:'var(--accent)' }}>SÉRIE</span>
        </h1>
        <p style={{ color:'var(--text-dim)', fontSize: 15, lineHeight: 1.5, marginTop: 20, maxWidth:'30ch' }}>
          Carga, reps e descanso de cada exercício — direto do banco, sem caderninho. O FORJA guarda tudo e mostra sua evolução.
        </p>

        <div style={{ marginTop:'auto', paddingBottom: 36 }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom: 22 }}>
            <div className="dots">
              <i className="on"/><i/><i/>
            </div>
            <span style={{ color:'var(--text-dim)', fontSize:13, fontWeight:600 }}>Pular</span>
          </div>
          <button className="btn primary cta">PRÓXIMO <Icon name="arrow" size={16}/></button>
        </div>
      </div>
    </div>
  );
}

function LoginMobile() {
  return (
    <div className="mob" data-screen-label="Login — Mobile" style={{ background:'var(--bg-0)' }}>
      <MobStatus/>
      {/* top brand band with shader */}
      <div style={{ position:'relative', height: 200, overflow:'hidden', display:'flex', alignItems:'center', justifyContent:'center' }}>
        <ShaderBackdrop intensity={0.9}/>
        <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg, transparent 40%, var(--bg-0) 100%)' }}/>
        <div className="f-display" style={{ position:'relative', fontSize: 76, letterSpacing:'0.02em' }}>
          FORJA<span style={{ color:'var(--accent)' }}>.</span>
        </div>
      </div>

      <div style={{ flex:1, padding:'12px 24px 0', display:'flex', flexDirection:'column' }}>
        <div className="seg" style={{ marginBottom: 24 }}>
          <button className="on">Entrar</button>
          <button>Criar conta</button>
        </div>

        <div className="col gap-4">
          <div>
            <div className="label-sm" style={{ marginBottom: 6 }}>Email</div>
            <input className="input" defaultValue="lucas.mendes@exemplo.com"/>
          </div>
          <div>
            <div style={{ display:'flex', justifyContent:'space-between', marginBottom: 6 }}>
              <div className="label-sm">Senha</div>
              <span style={{ fontSize:11, color:'var(--accent)' }}>Esqueceu?</span>
            </div>
            <input className="input" type="password" defaultValue="••••••••"/>
          </div>
          <button className="btn primary cta" style={{ marginTop: 8 }}>ENTRAR <Icon name="arrow" size={16}/></button>

          <div style={{ display:'flex', alignItems:'center', gap:12, margin:'6px 0' }}>
            <hr className="divider" style={{ flex:1 }}/>
            <span style={{ fontSize:11, color:'var(--text-faint)', letterSpacing:'0.15em' }}>OU</span>
            <hr className="divider" style={{ flex:1 }}/>
          </div>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>
            <button className="btn ghost" style={{ justifyContent:'center' }}>Google</button>
            <button className="btn ghost" style={{ justifyContent:'center' }}>Apple</button>
          </div>
        </div>

        <div style={{ marginTop:'auto', textAlign:'center', fontSize:13, color:'var(--text-dim)', padding:'24px 0 28px' }}>
          Ao entrar você aceita os <span style={{ color:'var(--text)' }}>Termos</span> e a <span style={{ color:'var(--text)' }}>Privacidade</span>.
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Onboarding, LoginMobile });
