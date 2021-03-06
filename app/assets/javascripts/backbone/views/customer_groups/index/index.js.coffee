App.Views.CustomerGroup.Index.Index = Backbone.View.extend
  el: '#customer-group-container'

  events:
    "click .customer-group": 'active'

  initialize: ->
    @model = App.customer_group # 与查询面板交互的桥梁
    self = this
    this.render()
    @model.bind 'change:id', -> self.switch()
    @model.set id: -1
    $('#save_group_button').live 'click', -> self.save() # 弹出的保存窗口
    @collection.bind 'add', (model, collection) ->
      new App.Views.CustomerGroup.Index.Show model: model # 回显新增分组
      self.model.set id: model.id

  render: ->
    # 默认分组:所有顾客、当前查询
    @collection.add [
      { id: -1, name: '所有顾客', term: '', query: '' },
      { id: 0 , name: '当前查询', term: '', query: '' }
    ]
    @collection.comparator = (model) -> model.id
    @collection.sort()
    @collection.each (model) -> new App.Views.CustomerGroup.Index.Show model: model

  active: (e) ->
    group = $(e.target).closest('.customer-group')
    group_id = parseInt group.attr('id').substr('customer_group_'.length)
    @model.set id: group_id

  switch: ->
    this.$('.customer-group.active').removeClass('active')
    $("#customer_group_#{@model.id}").show().addClass('active')
    customer_group = @collection.get(@model.id)
    $('#customer_group_0').hide() if @model.id isnt 0 #点击已保存分组则隐藏当前查询
    @model.set term: customer_group.get('term'), query: customer_group.get('query') #设置当前查询对象

  save: ->
    name = $('#new_group_name').val()
    if !name
      error_msg '名称不能为空'
      return false
    self = this
    group = App.customer_groups.get(0)
    attrs = customer_group: { name: name, term: group.get('term'), query: group.get('query') }
    $.post '/admin/customer_groups', attrs, (data) ->
      self.collection.add data
      $.unblockUI()
