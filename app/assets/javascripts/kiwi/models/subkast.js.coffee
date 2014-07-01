class FK.Models.Subkast extends Backbone.Model


class FK.Collections.SubkastList extends Backbone.Collection
  model: FK.Models.Subkast

  getUrlByCode: (code) =>
    subkast = @findWhere({code: code})
    return null if not subkast
    subkast.get('url')

  getCodeByUrl: (url) =>
    subkast = @findWhere({url: url})
    return null if not subkast
    subkast.get('code')

  getNameByCode: (code) =>
    subkast = @findWhere({code: code})
    return null if not subkast
    subkast.get('name')

  codes: () =>
    @pluck('code')

  namesAndCodes: () =>
    @map((subkast) =>
      subkast.pick("name", "code")
    )
