/* global React, Icon, MobStatus, BackHead */
// Treino em execução + Detalhe do exercício + Cronômetro de descanso

function TreinoExec() {
  const sets = [
    { reps: 10, carga: 26, done: true },
    { reps: 10, carga: 28, done: true, pr: true },
    { reps: 8, carga: 28, current: true },
    { reps: "", carga: 28 },
  ];
  return (
    <div className="mob" data-screen-label="Treino em Execução — Mobile">
      <MobStatus/>
      <div style={{ padding:'6px 20px 12px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <button style={{ background:'transparent', border:'none', color:'var(--text)' }}><Icon name="arrowL" size={24}/></button>
        <div style={{ display:'flex', flexDirection:'column', alignItems:'center', lineHeight: 1.35 }}>
          <span style={{ fontSize:10, color:'var(--text-dim)', letterSpacing:'0.15em' }}>EM TREINO</span>
          <span className="f-mono" style={{ fontSize:16, fontWeight:600, color:'var(--accent)' }}>24:18</span>
        </div>
        <button style={{ background:'transparent', border:'none', color:'var(--text)' }}><Icon name="more" size={22}/></button>
      </div>

      <div style={{ padding:'4px 20px 14px' }}>
        <div className="eyebrow">Exercício 02 / 07 · Peito</div>
        <h1 className="f-display" style={{ fontSize: 32, lineHeight: 1.08, margin:'6px 0 18px' }}>SUPINO INCLINADO HALTERES</h1>
        <div className="bar"><span style={{ width:'28%' }}/></div>
      </div>

      <div style={{ flex:1, overflow:'auto', padding:'0 16px' }}>
        <div className="card" style={{ padding: 0, marginBottom: 14 }}>
          <div style={{ display:'grid', gridTemplateColumns:'28px 1fr 1fr 36px', gap:10, padding:'12px 14px', borderBottom:'1px solid var(--hairline)', fontSize:10, color:'var(--text-dim)', letterSpacing:'0.1em', textTransform:'uppercase' }}>
            <div>#</div><div>Kg</div><div>Reps</div><div></div>
          </div>
          {sets.map((s, i) => (
            <div key={i} style={{ display:'grid', gridTemplateColumns:'28px 1fr 1fr 36px', gap:10, padding:'14px', alignItems:'center', borderBottom: i<sets.length-1?'1px solid var(--hairline)':'none', opacity: s.done?0.5:1, background: s.current?'var(--bg-2)':'transparent' }}>
              <div className="f-display" style={{ fontSize:18, color: s.current?'var(--accent)':'var(--text-dim)' }}>{i+1}</div>
              <div style={{ display:'flex', alignItems:'center', gap:6 }}>
                <input className="set-input" defaultValue={s.carga||''} placeholder="—" style={{ fontSize:14, padding:'6px 8px' }}/>
                {s.pr && <span className="chip success" style={{ padding:'1px 6px', fontSize:8 }}>PR</span>}
              </div>
              <input className="set-input" defaultValue={s.reps||''} placeholder="—" style={{ fontSize:14, padding:'6px 8px' }}/>
              <div className={"check" + (s.done?" checked":"")} style={{ width:22, height:22 }}>{s.done && <Icon name="check" size={12} stroke={3}/>}</div>
            </div>
          ))}
        </div>

        <div style={{ padding:'12px 16px', background:'var(--bg-1)', borderRadius:'var(--r-3)', border:'1px solid var(--hairline)' }}>
          <div className="label-sm">Próximo</div>
          <div style={{ display:'flex', alignItems:'center', gap:12, marginTop:8 }}>
            <div className="ph-img" style={{ width:44, height:44 }}/>
            <div style={{ flex:1 }}><div style={{ fontSize:14, fontWeight:600 }}>Crucifixo Polia Alta</div><div style={{ fontSize:11, color:'var(--text-dim)' }}>3×12-15 · 15kg</div></div>
            <Icon name="arrow" size={18}/>
          </div>
        </div>
      </div>

      <div style={{ padding:'14px 16px 28px', borderTop:'1px solid var(--hairline)', background:'#0a0b0c' }}>
        <button className="btn primary cta">CONCLUIR SÉRIE · DESCANSO 1:30</button>
      </div>
    </div>
  );
}

function DetalheExercicio() {
  return (
    <div className="mob" data-screen-label="Detalhe do Exercício — Mobile">
      <MobStatus/>
      {/* Media */}
      <div style={{ position:'relative' }}>
        <div className="ph-img" style={{ height: 280, borderRadius: 0, border:'none' }}/>
        <div style={{ position:'absolute', inset:0, background:'linear-gradient(180deg, rgba(0,0,0,0.4) 0%, transparent 30%, transparent 70%, var(--bg-0) 100%)' }}/>
        <div style={{ position:'absolute', top: 14, left: 16, right: 16, display:'flex', justifyContent:'space-between' }}>
          <button style={{ width:40, height:40, borderRadius:'50%', background:'rgba(0,0,0,0.5)', border:'none', color:'#fff', backdropFilter:'blur(4px)' }}><Icon name="arrowL" size={20}/></button>
          <button style={{ width:40, height:40, borderRadius:'50%', background:'rgba(0,0,0,0.5)', border:'none', color:'#fff', backdropFilter:'blur(4px)' }}><Icon name="plus" size={20}/></button>
        </div>
        <div style={{ position:'absolute', bottom: 14, left: '50%', transform:'translateX(-50%)', background:'rgba(0,0,0,0.55)', backdropFilter:'blur(4px)', padding:'8px 16px', borderRadius:99, display:'flex', alignItems:'center', gap:8, fontSize:12, fontWeight:600 }}>
          <Icon name="play" size={12}/> Ver demonstração
        </div>
      </div>

      <div style={{ flex:1, overflow:'auto', padding:'18px 20px 24px' }}>
        <h1 className="f-display" style={{ fontSize: 34, lineHeight: 1.08, margin: '0 0 14px' }}>SUPINO INCLINADO HALTERES</h1>
        <div style={{ display:'flex', gap:6, marginTop: 10, flexWrap:'wrap' }}>
          <span className="chip muscle">Peito superior</span>
          <span className="chip muscle">Deltoide ant.</span>
          <span className="chip">Halter</span>
          <span className="chip">Intermediário</span>
        </div>

        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:10, marginTop: 18 }}>
          <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>PR</div><div className="v" style={{ fontSize:24, color:'var(--accent)' }}>30kg</div></div>
          <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>Última</div><div className="v" style={{ fontSize:24 }}>28kg</div></div>
          <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>Sessões</div><div className="v" style={{ fontSize:24 }}>34</div></div>
        </div>

        <div style={{ marginTop: 22 }}>
          <div className="label-sm" style={{ marginBottom: 10 }}>EXECUÇÃO</div>
          <div className="col gap-3">
            {[
              "Sente no banco inclinado a 30–45°, halteres na altura do peito.",
              "Empurre os halteres para cima até quase estender os cotovelos.",
              "Desça de forma controlada (3s) sentindo o alongamento do peitoral.",
            ].map((t, i) => (
              <div key={i} style={{ display:'flex', gap:12 }}>
                <div className="f-display" style={{ fontSize:22, color:'var(--accent)', width: 24 }}>{i+1}</div>
                <div style={{ fontSize:14, color:'var(--text-dim)', lineHeight:1.45, flex:1 }}>{t}</div>
              </div>
            ))}
          </div>
        </div>

        <button className="btn primary cta" style={{ marginTop: 24 }}><Icon name="plus" size={16}/> Adicionar ao treino</button>
      </div>
    </div>
  );
}

function CronometroDescanso() {
  const r = 46, C = 2 * Math.PI * r;
  return (
    <div className="mob" data-screen-label="Cronômetro de Descanso — Mobile" style={{ background:'#0a0a0a' }}>
      <MobStatus/>
      <div style={{ padding:'6px 20px 12px', display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <button style={{ background:'transparent', border:'none', color:'var(--text)' }}><Icon name="arrowL" size={24}/></button>
        <div className="eyebrow">DESCANSO</div>
        <span style={{ fontSize:12, color:'var(--text-dim)', fontWeight:600 }}>PULAR</span>
      </div>

      <div style={{ flex:1, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', padding: 24, gap: 28 }}>
        <div style={{ position:'relative', width: 280, height: 280 }}>
          <svg viewBox="0 0 100 100" style={{ position:'absolute', inset:0, transform:'rotate(-90deg)' }}>
            <circle cx="50" cy="50" r={r} fill="none" stroke="var(--bg-2)" strokeWidth="3"/>
            <circle cx="50" cy="50" r={r} fill="none" stroke="var(--accent)" strokeWidth="3" strokeLinecap="round" strokeDasharray={C} strokeDashoffset={C*0.48}/>
          </svg>
          <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center' }}>
            <div style={{ fontSize:11, color:'var(--text-dim)', letterSpacing:'0.2em' }}>RESTAM</div>
            <div className="f-display" style={{ fontSize:110, lineHeight:0.9, color:'var(--accent)' }}>0:47</div>
            <div style={{ fontSize:11, color:'var(--text-faint)', letterSpacing:'0.15em', marginTop:6 }}>DE 1:30</div>
          </div>
        </div>

        <div className="card card-flat" style={{ width:'100%', padding: 18, maxWidth: 340 }}>
          <div className="label-sm" style={{ color:'var(--accent)' }}>PRÓXIMA SÉRIE</div>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginTop: 8 }}>
            <div><div className="f-display" style={{ fontSize:22 }}>SUPINO INCLINADO</div><div style={{ fontSize:12, color:'var(--text-dim)' }}>Série 3 de 4</div></div>
            <div style={{ textAlign:'right' }}><div className="f-display" style={{ fontSize:30, color:'var(--accent)' }}>28<span className="stat-unit" style={{ fontSize:12 }}>kg</span></div><div style={{ fontSize:11, color:'var(--text-dim)' }}>8 reps · RIR 2</div></div>
          </div>
        </div>
      </div>

      <div style={{ padding:'12px 20px 32px', display:'flex', gap:10 }}>
        <button className="btn lg" style={{ flex:1, justifyContent:'center' }}>-15s</button>
        <button className="btn lg" style={{ flex:1, justifyContent:'center' }}>+15s</button>
        <button className="btn primary lg" style={{ flex:2, justifyContent:'center' }}>INICIAR SÉRIE</button>
      </div>
    </div>
  );
}

Object.assign(window, { TreinoExec, DetalheExercicio, CronometroDescanso });
